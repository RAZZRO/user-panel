import 'package:flutter/material.dart';
import 'package:user_panel/widgets/custom_input_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_panel/models/user_model.dart';
import 'package:user_panel/widgets/custom_button.dart';
import 'package:user_panel/services/api_service.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserWidget();
}

class _EditUserWidget extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _saveIsSubmitting = false;
  bool _passIsSubmitting = false;
  bool _isLoading = true;

  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final firstName = prefs.getString('firstName');
    final lastName = prefs.getString('lastName');
    final phone = prefs.getString('phone');
    final nationalCode = prefs.getString('nationalCode');
    final startDate = prefs.getString('startDate');

    if (nationalCode == null ||
        firstName == null ||
        lastName == null ||
        phone == null ||
        startDate == null) {
      _getData();
    } else {
      final user = User(
        nationalCode: nationalCode,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        startDate: startDate,
      );
      setState(() {
        _user = user;
        _firstNameController = TextEditingController(text: user.firstName);
        _lastNameController = TextEditingController(text: user.lastName);
        _phoneController = TextEditingController(text: user.phone);
        _isLoading = false;
      });
    }
  }

  Future<void> _getData() async {
    try {
      final result = await ApiService.getRequest('user_information');
      if (result['success']) {
        final user = result['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('firstName', user['first_name']);
        await prefs.setString('lastName', user['last_name']);
        await prefs.setString('phone', user['phone']);
        await prefs.setString('nationalCode', user['id']);
        await prefs.setString('startDate', user['start_date']);

        setState(() {
          _user = User(
            nationalCode: user['id'],
            firstName: user['first_name'],
            lastName: user['last_name'],
            phone: user['phone'],
            startDate: user['start_date'],
          );
          _firstNameController = TextEditingController(text: user.firstName);
          _lastNameController = TextEditingController(text: user.lastName);
          _phoneController = TextEditingController(text: user.phone);
          _isLoading = false;
        });
      } else {
        var errorText;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorText),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ارتباط با سرور: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'رمز عبور نباید خالی باشد';
    if (value.length < 8) return 'رمز عبور باید حداقل 8 کاراکتر باشد';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _newPasswordController.text) return 'رمزها مطابقت ندارند';
    return null;
  }

  void _submitEditUser() async {
    if (_firstNameController.text == _user!.firstName &&
        _lastNameController.text == _user!.lastName &&
        _phoneController.text == _user!.phone) {
      _showDialog('خطا', 'هیچ تغییری انجام نشد');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _saveIsSubmitting = true;
        _passIsSubmitting = true;
      });

      final body = {
        'phone': _phoneController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
      };

      final result = await ApiService.postRequest('edit_user', body);
      setState(() {
        _saveIsSubmitting = false;
        _passIsSubmitting = false;
      });

      if (result['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('firstName', _firstNameController.text);
        await prefs.setString('lastName', _lastNameController.text);
        await prefs.setString('phone', _phoneController.text);

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('پیغام سیستم'),
            content: const Text('اطلاعات با موفقیت ثبت شد'),
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

        if (mounted) {
          Navigator.of(context).pop(true);
        }
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

  void _submitChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _saveIsSubmitting = true;
        _passIsSubmitting = true;
      });
      final body = {
        'oldPassword': _oldPasswordController.text,
        'newPassword': _newPasswordController.text,
      };

      final result = await ApiService.postRequest('change_password', body);
      setState(() {
        _saveIsSubmitting = false;
        _passIsSubmitting = false;
      });
      if (result['success']) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('پیغام سیستم'),
            content: const Text('رمز عبور جدید با موفقیت ثبت شد'),
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

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        String errorText;
        switch (result['statusCode']) {
          case 401:
            errorText = 'رمز عبور فعلی اشتباه است';
            break;
          case 408:
            errorText =
                'خطای اتصال به سرور. لطفا چند لحظه بعد مجدد تلاش فرمایید';
            break;
          case 500:
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
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.center,
          child: Text('ویرایش اطلاعات کاربری'),
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
                        controller:
                            TextEditingController(text: _user!.nationalCode),
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
                      ExpansionTile(
                        title: const Text('تغییر رمز عبور'),
                        children: [
                          const SizedBox(height: 16.0),
                          CustomInputField(
                            controller: _oldPasswordController,
                            label: 'رمز عبور فعلی',
                            validator: _validatePassword,
                            isPassword: true,
                          ),
                          const SizedBox(height: 16.0),
                          CustomInputField(
                            controller: _newPasswordController,
                            label: 'رمز عبور جدید',
                            validator: _validatePassword,
                            isPassword: true,
                          ),
                          const SizedBox(height: 16.0),
                          CustomInputField(
                            controller: _confirmPasswordController,
                            label: 'تأیید رمز عبور جدید',
                            validator: _validateConfirmPassword,
                            isPassword: true,
                          ),
                          const SizedBox(height: 16.0),
                          CustomButton(
                            onPressed: _submitChangePassword,
                            isSubmitting: _passIsSubmitting,
                            label: 'تغییر رمز عبور',
                          ),
                        ],
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
            ),
    );
  }
}
