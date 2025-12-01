import 'package:flutter/material.dart';
//import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:user_panel/widgets/custom_input_field.dart';
import 'package:user_panel/widgets/custom_button.dart';
import 'package:user_panel/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  bool isGeneral = true;
  int? selectedUnit;
  Jalali? selectedDate;
  TimeOfDay? selectedTime;
  final durationController = TextEditingController();
  bool _saveIsSubmitting = false;

  /// انتخاب تاریخ شمسی با پکیج persian_datetime_picker
  Future<void> _pickDate(BuildContext context) async {
    final Jalali now = Jalali.now();
    final Jalali oneYearLater = now.addYears(1);

    Jalali? picked = await showPersianDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: oneYearLater,
      initialEntryMode: PersianDatePickerEntryMode.calendarOnly,
      initialDatePickerMode: PersianDatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedTime = null; // ریست ساعت بعد از تغییر تاریخ
      });
    }
  }

  /// انتخاب ساعت شروع با TimePicker
  Future<void> _pickTime(BuildContext context) async {
    var picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      // بررسی زمان گذشته اگر تاریخ امروز انتخاب شده
      final Jalali today = Jalali.now();
      if (selectedDate != null &&
          selectedDate!.year == today.year &&
          selectedDate!.month == today.month &&
          selectedDate!.day == today.day) {
        final nowTime = TimeOfDay.now();
        if (picked.hour < nowTime.hour ||
            (picked.hour == nowTime.hour && picked.minute <= nowTime.minute)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("نمی‌توانید زمان گذشته را انتخاب کنید"),
            ),
          );
          return;
        }
      }

      setState(() {
        selectedTime = picked;
      });
    }
  }

  /// ثبت آبیاری
  void _submitIrrigation() async {
    if (durationController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null ||
        (!isGeneral && selectedUnit == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفاً همه فیلدها را تکمیل کنید")),
      );
      return;
    }

    setState(() => _saveIsSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final selectedDeviceIdentifier = prefs.getString(
      'selected_device_identifier',
    );

    if (selectedDeviceIdentifier == null) {
      if (!mounted) return;
      _showDialog(
        context,
        'خطا',
        'لطفا یک دستگاه انتخاب کنید و مجدد تلاش کنید',
      );
      setState(() => _saveIsSubmitting = false);
      return;
    }
    final now = DateTime.now(); // تاریخ و زمان فعلی به میلادی
    final miladiDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final jalaliNow = DateTimeExtensions(now).toJalali();
    final shamsiTime =
        "${jalaliNow.hour.toString().padLeft(2, '0')}:${jalaliNow.minute.toString().padLeft(2, '0')}:${jalaliNow.second.toString().padLeft(2, '0')}";
    final selectedDateStr =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    final selectedTimeStr =
        "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

    Map<String, dynamic> body;
    if (isGeneral) {
      body = {
        "deviceId": selectedDeviceIdentifier,
        "rule": "global",
        "date": selectedDateStr,
        "clock": selectedTimeStr,
        "duration": durationController.text,
        "timeStampDate": miladiDate,
        "timeStampClock": shamsiTime,
      };
    } else {
      body = {
        "deviceId": selectedDeviceIdentifier,
        "rule": "single",
        "rtu": selectedUnit,
        "date": selectedDateStr,
        "clock": selectedTimeStr,
        "duration": durationController.text,
        "timeStampDate": miladiDate,
        "timeStampClock": shamsiTime,
      };
    }

    final result = await ApiService.postRequest('set_irrigation', body);

    setState(() => _saveIsSubmitting = false);
    if (!mounted) return;

    if (result['data']) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("درخواست آبیاری ثبت شد")));

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("درخواست آبیاری با مشکل مواجه شد")),
      );
    }
  }

  void _submitIrrigationNow() async {
    if (durationController.text.isEmpty ||
        (!isGeneral && selectedUnit == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفاً مدت زمان آبیاری را مشخص کنید")),
      );
      return;
    }

    setState(() => _saveIsSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final selectedDeviceIdentifier = prefs.getString(
      'selected_device_identifier',
    );

    if (selectedDeviceIdentifier == null) {
      if (!mounted) return;
      _showDialog(
        context,
        'خطا',
        'لطفا یک دستگاه انتخاب کنید و مجدد تلاش کنید',
      );
      setState(() => _saveIsSubmitting = false);
      return;
    }
    final now = DateTime.now(); // تاریخ و زمان فعلی به میلادی
    final miladiDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final jalaliNow = DateTimeExtensions(now).toJalali();
    final shamsiTime =
        "${jalaliNow.hour.toString().padLeft(2, '0')}:${jalaliNow.minute.toString().padLeft(2, '0')}:${jalaliNow.second.toString().padLeft(2, '0')}";

    Map<String, dynamic> body;
    if (isGeneral) {
      body = {
        "deviceId": selectedDeviceIdentifier,
        "rule": "global",
        "message": "irrigationNow",
        "duration": durationController.text,
        "timeStampDate": miladiDate,
        "timeStampClock": shamsiTime,
      };
    } else {
      body = {
        "deviceId": selectedDeviceIdentifier,
        "rule": "single",
        "message": "irrigationNow",
        "rtu": selectedUnit,
        "duration": durationController.text,
        "timeStampDate": miladiDate,
        "timeStampClock": shamsiTime,
      };
    }

    final result = await ApiService.postRequest('set_irrigation', body);

    setState(() => _saveIsSubmitting = false);
    if (!mounted) return;

    if (result['data']) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("درخواست آبیاری ثبت شد")));

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("درخواست آبیاری با مشکل مواجه شد")),
      );
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('باشه'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("آبیاری"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// انتخاب نوع آبیاری
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text("آبیاری کلی"),
                    value: true,
                    groupValue: isGeneral,
                    onChanged: (value) => setState(() => isGeneral = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text("واحد خاص"),
                    value: false,
                    groupValue: isGeneral,
                    onChanged: (value) => setState(() => isGeneral = value!),
                  ),
                ),
              ],
            ),

            /// انتخاب واحدها
            if (!isGeneral)
              Wrap(
                spacing: 8,
                children: List.generate(5, (index) {
                  final unit = index + 1;
                  return ChoiceChip(
                    label: Text("واحد $unit"),
                    selected: selectedUnit == unit,
                    onSelected: (_) => setState(() => selectedUnit = unit),
                  );
                }),
              ),

            const SizedBox(height: 16),

            /// انتخاب تاریخ شمسی
            ElevatedButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(
                selectedDate != null
                    ? selectedDate!.formatFullDate()
                    : "انتخاب تاریخ شمسی",
              ),
              onPressed: () => _pickDate(context),
            ),

            const SizedBox(height: 12),

            /// انتخاب ساعت شروع
            ElevatedButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(
                selectedTime != null
                    ? "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}"
                    : "انتخاب زمان شروع",
              ),
              onPressed: () => _pickTime(context),
            ),

            const SizedBox(height: 16),

            /// مدت زمان آبیاری
            CustomInputField(
              controller: durationController,
              label: "مدت زمان آبیاری (دقیقه)",
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            /// دکمه‌های ثبت و انصراف
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('انصراف'),
                ),

                CustomButton(
                  onPressed: _submitIrrigation,
                  isSubmitting: _saveIsSubmitting,
                  label: 'ثبت',
                ),
                CustomButton(
                  onPressed: _submitIrrigationNow,
                  isSubmitting: _saveIsSubmitting,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer // رنگ برای dark mode
                      : Theme.of(
                          context,
                        ).colorScheme.inversePrimary, // رنگ برای light mode

                  textColor: Theme.of(context).colorScheme.onPrimaryFixed,
                  label: 'همین الان آبیاری کن',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
