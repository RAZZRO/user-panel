import 'package:flutter/material.dart';
//import 'dart:convert';
import 'package:user_panel/widgets/custom_input_field.dart';
//import 'package:user_panel/models/user_model.dart';
import 'package:user_panel/models/device.dart';
import 'package:user_panel/widgets/custom_button.dart';
import 'package:user_panel/services/api_service.dart';

class EditDeviceWidget extends StatefulWidget {
  const EditDeviceWidget({super.key, required this.device});

  final Device device;

  @override
  State<EditDeviceWidget> createState() => _EditUserWidget();
}

class _EditUserWidget extends State<EditDeviceWidget> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _deviceNameController;

  bool _saveIsSubmitting = false;

  @override
  void initState() {
    super.initState();
    _deviceNameController = TextEditingController(text: widget.device.name);
  }

  @override
  void dispose() {
    _deviceNameController.dispose();

    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'این فیلد نباید خالی باشد';
    if (value.length < 3) return 'حداقل ۳ کاراکتر وارد کنید';
    return null;
  }

  void _submitEdit() async {
    if (_deviceNameController.text == widget.device.name) {
      _showDialog('خطا', 'هیچ تغییری در نام دستگاه انجام نشد');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _saveIsSubmitting = true);

      const url = 'edit_device';
      final body = {
        'identifier': widget.device.identifier,
        'deviceName': _deviceNameController.text
      };

      final result = await ApiService.postRequest(url, body);
      setState(() => _saveIsSubmitting = false);

      if (result['success']) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('پیغام سیستم'),
            content: const Text('تغییر نام دستگاه با موفقیت انجام شد'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // فقط dialog رو می‌بنده
                },
                child: const Text('باشه'),
              ),
            ],
          ),
        );

        // بعد از بسته شدن dialog، این اجرا میشه:
        if (mounted) {
          Navigator.of(context)
              .pop(true); // صفحه ویرایش رو می‌بنده و true برمی‌گردونه
        }
      } else {
        String errorText;
        switch (result['statusCode']) {
          case 408:
            errorText =
                'خطای اتصال به سرور. لطفا چند لحظه بعد مجدد تلاش فرمایید';
            break;
          case 503:
            errorText = 'لطفا از اتصال به اینترنت اطمینان حاصل فرمایید';
            break;
          default:
            errorText = 'خطای ناشناخته';
        }
        _showDialog('خطا', errorText);
      }
    }
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            children: [
              const SizedBox(height: 20.0),
              CustomInputField(
                controller:
                    TextEditingController(text: widget.device.identifier),
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
                maxLength: 50,
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('انصراف'),
                  ),
                  CustomButton(
                    onPressed: _submitEdit,
                    isSubmitting: _saveIsSubmitting,
                    label: 'ثبت',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
