import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart'; // برای Clipboard

 import 'package:user_panel/widgets/custom_input_field.dart';
 import 'package:user_panel/models/user_model.dart';
 import 'package:user_panel/widgets/custom_button.dart';
 import 'package:user_panel/services/api_service.dart';

class EditUserWidget extends StatefulWidget {
  const EditUserWidget({super.key, required this.user});

  final User user;

  @override
  State<EditUserWidget> createState() => _EditUserWidget();
}

class _EditUserWidget extends State<EditUserWidget> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  bool _saveIsSubmitting = false;
  bool _deleteIsSubmitting = false;
  bool _passIsSubmitting = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'شماره تلفن نباید خالی باشد';
    if (value.length != 11 || !value.startsWith('09'))
      return 'شماره تلفن باید ۱۱ رقم و با 09 شروع شود';
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'این فیلد نباید خالی باشد';
    if (value.length < 3) return 'حداقل ۳ کاراکتر وارد کنید';
    return null;
  }

  void _submitEditUser() async {
    if (_firstNameController.text == widget.user.firstName &&
        _lastNameController.text == widget.user.lastName &&
        _phoneController.text == widget.user.phone) {
      _showDialog('خطا', 'هیچ تغییری انجام نشد');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _saveIsSubmitting = true);

      const url = 'http://10.0.2.2:3000/admin/edit_user';
      final body = {
        'nationalCode': widget.user.nationalCode,
        'phone': _phoneController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
      };

      final result = await ApiService.postRequest(url, body);
      setState(() => _saveIsSubmitting = false);

      print("++++++++++++++++++++++++++++++++++++++++");
      print(result);
      print(result['success']);

      if (result['success']) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('success'),
            content: const Text('edit user success'),
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
        _showDialog('خطا', result.toString());
      }
    }
  }

  void _submitDeleteUser() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف کاربر'),
        content: const Text(
          'آیا از حذف این کاربر مطمئن هستید؟\n\n'
          'با حذف کاربر، تمام اطلاعات مرتبط از جمله دستگاه‌ها و اطلاعات MQTT مربوطه نیز حذف خواهد شد. این عملیات غیرقابل بازگشت است.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('خیر'),
          ),
          CustomButton(
            onPressed: () => Navigator.of(context).pop(true),
            isSubmitting: false,
            label: 'بله، حذف کن',
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          )
          // ElevatedButton(
          //   onPressed: () => Navigator.of(context).pop(true),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.red,
          //   ),
          //   child: const Text('بله، حذف کن'),
          // ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _deleteIsSubmitting = true);

      const url = 'http://10.0.2.2:3000/admin/delete_user';
      final body = {
        'nationalCode': widget.user.nationalCode,
      };

      final result = await ApiService.postRequest(url, body);
      setState(() => _deleteIsSubmitting = false);

      print("++++++++++++++++++++++++++++++++++++++++");
      print(result);
      print(result['success']);

      if (result['success']) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('success'),
            content: const Text('delete user success'),
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
        _showDialog('خطا', result.toString());
      }
    }
  }

  void _submitResetPassword() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('بازنشانی کلمه عبور'),
        content: const Text(
          'آیا از بازنشانی کلمه عبور کاربر مطمئن هستید؟\n\n'
          'با بازنشانی کلمه عبور، کلمه عبور کاربر به حالت پیش‌فرض بازنشانی می‌شود.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('خیر'),
          ),
          CustomButton(
            onPressed: () => Navigator.of(context).pop(true),
            isSubmitting: false,
            label: 'بله، بازنشانی کن',
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          )
          // ElevatedButton(
          //   onPressed: () => Navigator.of(context).pop(true),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.red,
          //   ),
          //   child: const Text('بله، حذف کن'),
          // ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _passIsSubmitting = true);

      const url = 'http://10.0.2.2:3000/admin/reset_password';
      final body = {
        'nationalCode': widget.user.nationalCode,
      };

      final result = await ApiService.postRequest(url, body);
      setState(() => _passIsSubmitting = false);

      print("++++++++++++++++++++++++++++++++++++++++");
      print(result);
      print(result['success']);

      if (result['success']) {
        final dataMap = json.decode(result['data']); // تبدیل رشته به Map
        final message = dataMap['password'];
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('success'),
            content: Text(
              "new password: $message",
              //result.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: message));
                  Navigator.of(context).pop(); // بستن دیالوگ
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('متن کپی شد')),
                  );
                },
                child: const Text('کپی'),
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
        _showDialog('خطا', result.toString());
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
                    TextEditingController(text: widget.user.nationalCode),
                label: 'کد ملی',
                isEditable: false,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              CustomInputField(
                controller: _firstNameController,
                label: 'نام',
                validator: _validateName,
                isEditable: true,
                maxLength: 50,
              ),
              const SizedBox(height: 16.0),
              CustomInputField(
                controller: _lastNameController,
                label: 'نام خانوادگی',
                validator: _validateName,
                isEditable: true,
                maxLength: 50,
              ),
              const SizedBox(height: 16.0),
              CustomInputField(
                controller: _phoneController,
                label: 'شماره تلفن',
                validator: _validatePhone,
                keyboardType: TextInputType.phone,
                isEditable: true,
                maxLength: 11,
              ),
              const SizedBox(height: 20.0),
              CustomButton(
                onPressed: _submitResetPassword,
                isSubmitting: _passIsSubmitting,
                label: 'بازنشانی کلمه عبور',
              ),
              CustomButton(
                onPressed: _submitDeleteUser,
                isSubmitting: _deleteIsSubmitting,
                label: 'حذف کاربر',
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
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
                    onPressed: _submitEditUser,
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
