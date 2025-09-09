import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_panel/screens/home_screen.dart';
import 'package:user_panel/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nationalCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final result = await ApiService.login('login', {
        'nationalCode': _nationalCodeController.text,
        'password': _passwordController.text,
      });
      print(result['success']);
      print(result['statusCode']);
      print(result['error']);

      if (result['success']) {
        final token = result['data']['token'];
        final user = result['data']['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('firstName', user['firstName']);
        await prefs.setString('lastName', user['lastName']);
        await prefs.setString('phone', user['phone']);
        await prefs.setString('nationalCode', user['id']);
        await prefs.setString('startDate', user['startDate']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        var errorText;
        switch (result['statusCode']) {
          case 401:
            errorText = 'ورود ناموفق: نام کاربری یا رمز عبور نادرست است';
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
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool isValidIranianNationalCode(String input) {
    if (!RegExp(r'^\d{10}$').hasMatch(input)) return false;

    if (RegExp(r'^(\d)\1{9}$').hasMatch(input)) return false;

    final check = int.parse(input[9]);
    final sum = List.generate(9, (i) => int.parse(input[i]) * (10 - i))
        .reduce((a, b) => a + b);
    final remainder = sum % 11;

    return (remainder < 2 && check == remainder) ||
        (remainder >= 2 && check == 11 - remainder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.center,
          child: Text('ورود به پنل کاربری'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nationalCodeController,
                decoration: const InputDecoration(labelText: 'کد ملی'),
                keyboardType: TextInputType.number,
                maxLength: 10,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'وارد کردن کد ملی الزامی است';
                  } else if (!RegExp(r'^\d{10}$').hasMatch(val)) {
                    return 'کد ملی باید شامل ۱۰ رقم باشد';
                  } else if (!isValidIranianNationalCode(val)) {
                    return 'کد ملی نامعتبر است';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'رمز عبور',
                  suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      }),
                ),
                obscureText: _obscureText,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'وارد کردن رمز عبور الزامی است';
                  } else if (val.length < 8) {
                    return 'رمز عبور باید حداقل ۸ کاراکتر باشد';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _login,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ))
                    : const Text('ورود'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
