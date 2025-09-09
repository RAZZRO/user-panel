import 'package:flutter/material.dart';
import 'package:user_panel/models/Information_model.dart';
import 'package:user_panel/services/sqlite_database.dart';
import 'package:user_panel/widgets/custom_input_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:user_panel/widgets/custom_button.dart';
import 'package:user_panel/services/api_service.dart';

class EditDeviceScreen extends StatefulWidget {
  const EditDeviceScreen({super.key});

  @override
  State<EditDeviceScreen> createState() => _EditUserWidget();
}

class _EditUserWidget extends State<EditDeviceScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _deviceNameController;

  bool _saveIsSubmitting = false;
  bool _isLoading = true;

  DeviceInfo? _deviceInfo;

  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }

  Future<void> _loadDeviceData() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedDeviceIdentifier =
        prefs.getString('selected_device_identifier');

    if (selectedDeviceIdentifier == null) {
      _showDialog('خطا', 'لطفا یک دستگاه انتخاب کنید و مجدد تلاش کنید');
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final cached =
        await DeviceDatabase.getDevice(int.parse(selectedDeviceIdentifier));

    if (cached != null) {
      _deviceInfo = cached;
    } else {
      final result = await ApiService.postRequest(
        'device_information',
        {'identifier': selectedDeviceIdentifier},
      );

      if (result['statusCode'] == 200 &&
          result['data'] != null &&
          result['data']['device_identifier'] != null) {
        final device = DeviceInfo.fromJson(result['data']);
        await DeviceDatabase.insertDevice(device);
        _deviceInfo = device;
      } else {
        _showErrorByStatusCode(result['statusCode']);
      }
    }

    setState(() {
      _deviceNameController =
          TextEditingController(text: _deviceInfo?.deviceName ?? '');
      _isLoading = false;
    });
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'این فیلد نباید خالی باشد';
    if (value.length < 3) return 'حداقل ۳ کاراکتر وارد کنید';
    return null;
  }

  Future<void> _submitEditDevice() async {
    if (_deviceNameController.text == _deviceInfo?.deviceName) {
      _showDialog('خطا', 'هیچ تغییری انجام نشد');
      return;
    }

    if (_formKey.currentState!.validate()) {
      print("start editing");
      setState(() => _saveIsSubmitting = true);

      final body = {
        'identifier': _deviceInfo?.identifier,
        'deviceName': _deviceNameController.text,
      };

      final result = await ApiService.postRequest('edit_device', body);

      print("edit done");
      print(result);
      print(result['success']);

      if (result['success']) {
        print("come into if");
        final updatedDevice = DeviceInfo(
          identifier: _deviceInfo!.identifier,
          deviceName: _deviceNameController.text,
          batteryCharge: _deviceInfo?.batteryCharge,
          internet: _deviceInfo?.internet,
          rain: _deviceInfo?.rain,
          simCharge: _deviceInfo?.simCharge,
          windDirection: _deviceInfo?.windDirection,
          timestamp: _deviceInfo?.timestamp,
        );
        print("object");

        await DeviceDatabase.insertDevice(updatedDevice);
        setState(() => _saveIsSubmitting = false);
        print("swhowwwwwwwwwwwwwwwwwwwwwwwwww");

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('پیغام سیستم'),
            content: const Text('اطلاعات دستگاه با موفقیت ثبت شد'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('باشه'),
              ),
            ],
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        String errorText;
        switch (result['statusCode']) {
          case 500:
            errorText =
                'خطای اتصال به سرور. لطفا چند لحظه بعد مجدد تلاش فرمایید';
            break;
          case 408:
            errorText =
                'خطای اتصال به سرور. لطفا چند لحظه بعد مجدد تلاش فرمایید';
            break;
          case 404:
            errorText =
                'اطلاعات کاربر یافت نشد.لطفا با پشتیبانی تماس حاصل فرمایید';
            break;
          case 503:
            errorText = 'لطفا از اتصال به اینترنت اطمینان حاصل فرمایید';
            break;
          default:
            errorText = 'خطای ناشناخته';
        }
        setState(() => _saveIsSubmitting = false);

        _showDialog('خطا', errorText);
      }
    }
  }

  void _showErrorByStatusCode(int? statusCode) {
    String errorText;
    switch (statusCode) {
      case 500:
      case 408:
        errorText = 'خطای اتصال به سرور. لطفا چند لحظه بعد مجدد تلاش فرمایید';
        break;
      case 400:
        errorText = 'اطلاعات یافت نشد. لطفا با پشتیبانی تماس بگیرید';
        break;
      case 503:
        errorText = 'لطفا از اتصال به اینترنت اطمینان حاصل فرمایید';
        break;
      default:
        errorText = 'خطای ناشناخته';
    }
    _showDialog('خطا', errorText);
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.center,
          child: Text('اطلاعات دستگاه'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView(
                    children: [
                      const SizedBox(height: 20.0),
                      CustomInputField(
                        controller: TextEditingController(
                          text: _deviceInfo?.identifier.toString(),
                        ),
                        label: 'شناسه دستگاه',
                        isEditable: false,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16.0),
                      CustomInputField(
                        controller: _deviceNameController,
                        label: 'نام دستگاه',
                        validator: _validateName,
                        isEditable: true,
                        maxLength: 20,
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('انصراف'),
                          ),
                          ElevatedButton(
                            onPressed:
                                _saveIsSubmitting ? null : _submitEditDevice,
                            child: _saveIsSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                    ))
                                : const Text('ثبت'),
                          ),
                          // CustomButton(
                          //   onPressed: _submitEditDevice,
                          //   isSubmitting: _saveIsSubmitting,
                          //   label: 'ثبت',
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
