import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:user_panel/widgets/rtu_information.dart';
import 'package:user_panel/models/Information_model.dart';
import 'package:user_panel/services/api_service.dart';
import 'package:user_panel/services/sqlite_database.dart';

class RtuScreen extends StatelessWidget {
  const RtuScreen({super.key});

  // شبیه‌سازی داده‌ها
  final List<Map<String, dynamic>> rtuUnits = const [
    {
      "unit": 1,
      "status": 0, // تعیین نشده
      "irrigationDateTime": null,
      "irrigationDuration": null,
      "humidity": 65,
      "airTemp": 28,
      "soilTemp": 22,
      "ph": 6.5,
      "ec": 1.8,
      "co2": 400,
      "timestamp": "1404/06/15 12:45",
    },
    {
      "unit": 2,
      "status": 1, // برنامه‌ریزی شده
      "irrigationDateTime": "1404/06/15 12:00",
      "irrigationDuration": "15 دقیقه",
      "humidity": 70,
      "airTemp": 30,
      "soilTemp": 23,
      "ph": 6.8,
      "ec": 2.1,
      "co2": 420,
      "timestamp": "1404/06/15 12:40",
    },
    {
      "unit": 3,
      "status": 2, // در حال آبیاری
      "irrigationDateTime": "1404/06/15 14:15",
      "irrigationDuration": "25 دقیقه",
      "humidity": 60,
      "airTemp": 27,
      "soilTemp": 21,
      "ph": 6.2,
      "ec": 1.6,
      "co2": 390,
      "timestamp": "1404/06/15 12:30",
    },
    {
      "unit": 4,
      "status": 1,
      "irrigationDateTime": "1404/06/15 15:45",
      "irrigationDuration": "30 دقیقه",
      "humidity": 68,
      "airTemp": 29,
      "soilTemp": 22,
      "ph": 6.4,
      "ec": 1.9,
      "co2": 410,
      "timestamp": "1404/06/15 12:20",
    },
    {
      "unit": 5,
      "status": 0,
      "irrigationDateTime": null,
      "irrigationDuration": null,
      "humidity": 72,
      "airTemp": 31,
      "soilTemp": 24,
      "ph": 6.7,
      "ec": 2.2,
      "co2": 430,
      "timestamp": "1404/06/15 12:10",
    },
  ];

  Color _getCardColor(int status) {
    switch (status) {
      case 1:
        return Colors.blue.shade100;
      case 2:
        return Colors.green.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 1:
        return Icons.schedule;
      case 2:
        return Icons.water_drop;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _fetchAndSaveDeviceData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedDeviceIdentifier = prefs.getString(
      'selected_device_identifier',
    );

    if (selectedDeviceIdentifier == null) {
      _showDialog(
        context,
        'خطا',
        'لطفا یک دستگاه انتخاب کنید و مجدد تلاش کنید',
      );
      if (context.mounted) Navigator.of(context).pop();
      return;
    }

    final result = await ApiService.postRequest('rtu_information', {
      'identifier': selectedDeviceIdentifier,
    });

    if (result != null) {
      print(result);
      dynamic rows;

      // حالت ۱: نتیجه مستقیماً یک لیست است
      if (result is List) {
        rows = result;
      }
      // حالت ۲: نتیجه یک Map است که لیست داخلش است (مثلا {"data": [...]})
      else if (result is Map<String, dynamic> && result['data'] is List) {
        rows = result['data'];
      }
      // حالت ۳: فقط یک رکورد تکی Map است
      else if (result is Map<String, dynamic>) {
        rows = [result];
      }

      if (rows != null && rows is List && rows.isNotEmpty) {
        for (final row in rows) {
          if (row is Map<String, dynamic>) {
            final irrigation = IrrigationData.fromJson(row);
            await DeviceDatabase.insertIrrigation(irrigation);

            final rtu = RtuData.fromJson(row);
            await DeviceDatabase.insertRtu(rtu);
          }
        }
      }
    }
    print("saving done ");
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

  Future<void> printStoredData(String deviceId) async {
    print("object................................");
    // گرفتن دیتاهای irrigation
    final irrigationList = await DeviceDatabase.getIrrigationData(deviceId);
    print("=== Irrigation Data for device $deviceId ===");
    if (irrigationList.isEmpty) {
      print("هیچ دیتای آبیاری ذخیره نشده است.");
    } else {
      for (var item in irrigationList) {
        print(item.toMap());
      }
    }

    // گرفتن دیتاهای rtu
    final rtuList = await DeviceDatabase.getRtuData(deviceId);
    print("=== RTU Data for device $deviceId ===");
    if (rtuList.isEmpty) {
      print("هیچ دیتای RTU ذخیره نشده است.");
    } else {
      for (var item in rtuList) {
        print(item.toMap());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("کنترل واحد ها"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "بروزرسانی",
            onPressed: () async {
              await _fetchAndSaveDeviceData(context);
              await printStoredData("99624574"); // اینجا device_id خودت رو بذار
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: rtuUnits.length,
        itemBuilder: (context, index) {
          final unit = rtuUnits[index];
          final status = unit["status"] as int;

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RtuInformation(unitData: unit),
                ),
              );
            },
            child: Card(
              color: _getCardColor(status),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// عنوان واحد + آیکون وضعیت
                    Row(
                      children: [
                        Icon(_getStatusIcon(status), color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          "واحد ${unit["unit"]}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    /// وضعیت آبیاری
                    Text(
                      status == 0
                          ? "وضعیت آبیاری: تعیین نشده"
                          : status == 1
                          ? "وضعیت آبیاری: برنامه‌ریزی شده"
                          : "وضعیت آبیاری: در حال آبیاری",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 6),

                    /// زمان و مدت آبیاری برای وضعیت‌های برنامه‌ریزی شده و در حال آبیاری
                    if (status != 0) ...[
                      Row(
                        children: [
                          const Icon(Icons.date_range, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "زمان آبیاری: ${unit["irrigationDateTime"]}",
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
                              "مدت آبیاری: ${unit["irrigationDuration"]}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      /// دکمه لغو آبیاری
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "آبیاری واحد ${unit["unit"]} لغو شد ❌",
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.cancel),
                          label: const Text("لغو آبیاری"),
                        ),
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
