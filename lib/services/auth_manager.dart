// auth_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_panel/screens/logIn_screen.dart';
import 'package:user_panel/services/sqlite_database.dart';

class AuthManager {
  static Future<void> logoutAndRedirect(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await DeviceDatabase.clearAllData();


    // هدایت به صفحه Login و پاک کردن تاریخچه صفحات
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );

    // نمایش پیام
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('لطفا مجدد وارد شوید')));
  }
}
