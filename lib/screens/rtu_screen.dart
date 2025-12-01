import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_panel/models/Information_model.dart';
import 'package:user_panel/services/api_service.dart';
import 'package:user_panel/services/sqlite_database.dart';
import 'package:user_panel/widgets/rtu_information.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:user_panel/widgets/custom_button.dart';
import 'package:user_panel/services/auth_manager.dart';

class RtuScreen extends StatefulWidget {
  const RtuScreen({super.key});

  @override
  State<RtuScreen> createState() => _RtuScreenState();
}

class _RtuScreenState extends State<RtuScreen> {
  List<IrrigationData> _irrigationList = [];
  bool _isLoading = false;
  Set<String> _isCancellIrrigationMap = {};

  Color _getCardColor(BuildContext context, String? mode) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (mode == "set") {
      return isDark ? Colors.blueGrey.shade700 : Colors.blue.shade100;
    } else if (mode == "run") {
      return isDark ? Colors.green.shade700 : Colors.green.shade100;
    } else if (mode == "off") {
      return isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    }
    return isDark ? Colors.grey.shade900 : Colors.grey.shade200;
  }

  IconData _getStatusIcon(String? mode) {
    switch (mode) {
      case "run":
        return Icons.water_drop;
      case "set":
        return Icons.schedule;
      case "off":
        return Icons.power_off;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _fetchAndSaveDeviceData() async {
    setState(() {
      _isLoading = true;
    });
    print("fetch");
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
      setState(() => _isLoading = false);
      return;
    }
    final now = DateTime.now(); // تاریخ و زمان فعلی به میلادی
    final miladiDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final jalaliNow = now.toJalali();
    final shamsiTime =
        "${jalaliNow.hour.toString().padLeft(2, '0')}:${jalaliNow.minute.toString().padLeft(2, '0')}:${jalaliNow.second.toString().padLeft(2, '0')}";

    try {
      final result = await ApiService.postRequest('rtu_information', {
        'deviceId': selectedDeviceIdentifier,
        'timeStampDate': miladiDate,
        'timeStampClock': shamsiTime,
      });

      print(result);

      // const url = 'all_topics';
      // final result = await ApiService.getRequest(url);

      if (result['success'] == true) {
        if (result['data'] is List) {
          final data = result['data'] as List;
          for (final row in data) {
            if (row['irrigation_id'] == null) continue;
            final irrigation = IrrigationData.fromJson(row);
            await DeviceDatabase.insertIrrigation(irrigation);

            if (row['rtu_data_id'] == null) continue;
            final rtu = RtuData.fromJson(row);
            await DeviceDatabase.insertRtu(rtu);
          }
        }

        await _loadStoredData();
      } else {
        if (!mounted) {
          return;
        }
        if (result['statusCode'] == 401) {
          AuthManager.logoutAndRedirect(context);
        }
        _showDialog(context, 'خطا', 'دریافت داده جدید با مشکل مواجه شد.');
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showDialog(context, 'خطا', 'خطا در ارتباط با سرور: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedDeviceIdentifier = prefs.getString(
      'selected_device_identifier',
    );
    if (selectedDeviceIdentifier == null) return;

    final irrigationList = await DeviceDatabase.getIrrigationData(
      int.parse(selectedDeviceIdentifier),
    );
    // مرتب‌سازی بر اساس rtuId
    irrigationList.sort((a, b) => (a.rtuId ?? '').compareTo(b.rtuId ?? ''));

    setState(() {
      _irrigationList = irrigationList;
    });

    print("=== Irrigation Data loaded ===");
    for (var item in irrigationList) {
      print(item.toMap());
    }
  }

  Future<void> _cancellIrrigation(String rtuId) async {
    setState(() => _isCancellIrrigationMap.add(rtuId));

    final prefs = await SharedPreferences.getInstance();
    final selectedDeviceIdentifier = prefs.getString(
      'selected_device_identifier',
    );

    final now = DateTime.now();
    final miladiDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final jalaliNow = DateTimeExtensions(now).toJalali();
    final shamsiTime =
        "${jalaliNow.hour.toString().padLeft(2, '0')}:${jalaliNow.minute.toString().padLeft(2, '0')}:${jalaliNow.second.toString().padLeft(2, '0')}";

    Map<String, dynamic> body = {
      "deviceId": selectedDeviceIdentifier,
      "rtu": rtuId,
      "timeStampDate": miladiDate,
      "timeStampClock": shamsiTime,
    };

    final result = await ApiService.postRequest('cancell_irrigation', body);

    setState(() => _isCancellIrrigationMap.remove(rtuId));
    if (!mounted) return;

    if (result['data']) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("درخواست لغو آبیاری ثبت شد")),
      );
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("درخواست لغو آبیاری با مشکل مواجه شد")),
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
  void initState() {
    super.initState();
    _loadStoredData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text("کنترل واحدها"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "بروزرسانی",
            onPressed: () async {
              await _fetchAndSaveDeviceData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _irrigationList.isEmpty
          ? const Center(child: Text("داده‌ای برای نمایش وجود ندارد"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _irrigationList.length,
              itemBuilder: (context, index) {
                final unit = _irrigationList[index];
                final mode = unit.mode;
                final color = _getCardColor(context, mode);

                return Card(
                  color: color,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RtuInformation(
                            deviceId: unit.deviceId,
                            rtuId: unit.rtuId.toString(),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(_getStatusIcon(mode), color: textColor),
                              const SizedBox(width: 8),
                              Text(
                                "واحد ${unit.rtuId}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            unit.mode == 'off'
                                ? "وضعیت آبیاری: تعیین نشده"
                                : unit.mode == 'set'
                                ? "وضعیت آبیاری: برنامه‌ریزی شده"
                                : unit.mode == 'run'
                                ? "وضعیت آبیاری: در حال آبیاری"
                                : "نامشخص",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),

                          // فقط اطلاعات مربوط به زمان آبیاری و مدت در صورتی که off نباشد
                          if (unit.mode == 'set' || unit.mode == 'run') ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.date_range,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "زمان آبیاری: ${unit.startDate ?? 'نامشخص'}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.timer, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "مدت آبیاری: ${unit.duration ?? 'نامشخص'} دقیقه",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],

                          // 👇 این بخش همیشه نمایش داده می‌شود
                          Row(
                            children: [
                              const Icon(Icons.update, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "زمان بروزرسانی: ${unit.timestamp ?? 'نامشخص'}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),

                          // دکمه لغو فقط وقتی حالت set یا run باشد
                          if (unit.mode == 'set' || unit.mode == 'run') ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: CustomButton(
                                onPressed: () =>
                                    _cancellIrrigation(unit.rtuId.toString()),
                                isSubmitting: _isCancellIrrigationMap.contains(
                                  unit.rtuId.toString(),
                                ),
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                icon: const Icon(Icons.cancel),
                                label: 'ثبت',
                              ),

                              //  ElevatedButton.icon(
                              //   onPressed: _cancellIrrigation,
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: Colors.red,
                              //     foregroundColor: Colors.white,
                              //   ),
                              //   icon: const Icon(Icons.cancel),
                              //   label: const Text("لغو آبیاری"),
                              // ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
