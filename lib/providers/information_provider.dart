//import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_panel/models/Information_model.dart';
import 'package:user_panel/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_panel/services/sqlite_database.dart';

final deviceInfoProvider = FutureProvider<DeviceInfo>((ref) async {
  final prefs = await SharedPreferences.getInstance();

  final selectedDeviceIdentifier =
      prefs.getString('selected_device_identifier');

  final result = await ApiService.postRequest(
    'device_info',
    {'identifier': selectedDeviceIdentifier},
  );

  if (result['statusCode'] == 200) {
    final device = DeviceInfo.fromJson((result['data']));
    await DeviceDatabase.insertDevice(device); // ذخیره در SQLite
    return device;
  } else {
    // اگر API خراب بود، تلاش کن از دیتابیس بخونی
    final cached =
        await DeviceDatabase.getDevice(int.parse(selectedDeviceIdentifier!));
    if (cached != null) return cached;

    throw Exception('دریافت اطلاعات از سرور و حافظه محلی شکست خورد');
  }
});
