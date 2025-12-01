import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_panel/models/Information_model.dart';
import 'package:user_panel/services/api_service.dart';
import 'package:user_panel/services/sqlite_database.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:user_panel/services/auth_manager.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  bool _saveIsSubmitting = false;
  bool _isLoading = false;
  List<StackData> _stackList = [];
  List<RelayData> _relayList = [];
  List<double> tanks = [];
  List<bool> relays = [];

  /// رنگ مخزن بر اساس درصد
  Color getTankColor(double level) {
    if (level < 20) return Colors.red;
    if (level < 80) return Colors.blue;
    return Colors.green;
  }

  /// رنگ رله روشن/خاموش با توجه به تم
  Color getRelayColor(bool isOn, BuildContext context) {
    if (!isOn) return Colors.grey;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode
        ? const Color.fromARGB(255, 222, 222, 35)
        : const Color.fromARGB(255, 216, 216, 23);
  }

  /// ویجت دایره‌ای مخزن با انیمیشن و تراز وسط
  Widget _buildTankCircle(String name, double level) {
    final color = getTankColor(level);
    return SizedBox(
      width: 120,
      height: 160,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // وسط عمودی
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: level / 100),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 12,
                      color: color,
                      backgroundColor: color.withOpacity(0.3),
                    ),
                  ),
                  Text(
                    "${(value * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  /// ویجت رله
  Widget _buildRelayTile(int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(
          Icons.lightbulb,
          color: getRelayColor(relays[index], context),
        ),
        title: Text("چراغ ${index + 1}"),
        trailing: Switch(
          value: relays[index],
          onChanged: (val) {
            setState(() {
              relays[index] = val;
            });
          },
        ),
      ),
    );
  }

  /// دریافت و ذخیره اطلاعات جدید دستگاه
  Future<void> _fetchAndSaveDeviceData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final selectedDeviceIdentifier = prefs.getString(
      'selected_device_identifier',
    );

    if (selectedDeviceIdentifier == null) {
      if (!mounted) return;
      _showDialog(
        context,
        'خطا',
        'لطفاً یک دستگاه انتخاب کنید و مجدد تلاش کنید.',
      );
      setState(() => _isLoading = false);
      return;
    }

    final now = DateTime.now();
    final miladiDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final jalaliNow = now.toJalali();
    final shamsiTime =
        "${jalaliNow.hour.toString().padLeft(2, '0')}:${jalaliNow.minute.toString().padLeft(2, '0')}:${jalaliNow.second.toString().padLeft(2, '0')}";

    try {
      final result = await ApiService.postRequest('stack_information', {
        'deviceId': selectedDeviceIdentifier,
        'timeStampDate': miladiDate,
        'timeStampClock': shamsiTime,
      });
      print(result);

      if (result['success'] == true) {
        print("success true");
        // ابتدا مطمئن شو data Map است
        final data = result['data'] as Map<String, dynamic>?;

        if (data != null) {
          // ذخیره stack ها
          final stacks = data['stacks'] as List<dynamic>? ?? [];
          print(stacks);
          for (final row in stacks) {
            print("save stack: $row");
            final stack = StackData.fromJson(row as Map<String, dynamic>);
            await DeviceDatabase.insertStack(stack);
          }

          // ذخیره relay ها
          final relays = data['relays'] as List<dynamic>? ?? [];
          for (final row in relays) {
            print("save relay: $row");
            final relay = RelayData.fromJson(row as Map<String, dynamic>);
            await DeviceDatabase.insertRelay(relay);
          }
        }

        await _loadStoredData();
      } else {
        if (!mounted) return;
        if (result['statusCode'] == 401) {
          AuthManager.logoutAndRedirect(context);
        }
        _showDialog(context, 'خطا', 'دریافت داده جدید با مشکل مواجه شد.');
      }
    } catch (e) {
      if (!mounted) return;
      _showDialog(context, 'خطا', 'خطا در ارتباط با سرور: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedDeviceIdentifier = prefs.getString(
      'selected_device_identifier',
    );
    if (selectedDeviceIdentifier == null) return;

    final stackList = await DeviceDatabase.getStackData(
      int.parse(selectedDeviceIdentifier),
    );
    final relayList = await DeviceDatabase.getRelayData(
      int.parse(selectedDeviceIdentifier),
    );

    stackList.sort(
      (a, b) => a.tankId.toString().compareTo(b.tankId.toString()),
    );
    relayList.sort(
      (a, b) => a.relayId.toString().compareTo(b.relayId.toString()),
    );

    setState(() {
      _stackList = stackList;
      _relayList = relayList;
      tanks = stackList.map((s) => s.wLevel?.toDouble() ?? 0.0).toList();
      relays = relayList.map((r) => r.state ?? false).toList();
    });
  }

  Future<void> _submitRelay() async {
    if (_relayList.isEmpty || relays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("هیچ رله‌ای برای تغییر وجود ندارد")),
      );
      return;
    }

    bool hasChange = false;
    for (int i = 0; i < relays.length; i++) {
      if (i < _relayList.length &&
          relays[i] != (_relayList[i].state ?? false)) {
        hasChange = true;
        break;
      }
    }

    if (!hasChange) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("هیچ تغییری انجام نشده است")),
      );
      return;
    }

    setState(() => _saveIsSubmitting = true);
    final prefs = await SharedPreferences.getInstance();
    final selectedDeviceIdentifier = prefs.getString(
      'selected_device_identifier',
    );

    if (selectedDeviceIdentifier == null) {
      _showDialog(context, 'خطا', 'لطفاً یک دستگاه انتخاب کنید.');
      setState(() => _saveIsSubmitting = false);
      return;
    }

    final now = DateTime.now();
    final miladiDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final jalaliNow = now.toJalali();
    final shamsiTime =
        "${jalaliNow.hour.toString().padLeft(2, '0')}:${jalaliNow.minute.toString().padLeft(2, '0')}:${jalaliNow.second.toString().padLeft(2, '0')}";

    final body = {
      "deviceId": selectedDeviceIdentifier,
      "timeStampDate": miladiDate,
      "timeStampClock": shamsiTime,
      for (int i = 0; i < relays.length; i++) "r${i + 1}": relays[i].toString(),
    };

    final result = await ApiService.postRequest('set_relay', body);
    setState(() => _saveIsSubmitting = false);

    if (result['data'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("درخواست تغییر چراغ‌ها ثبت شد")),
      );
      if (mounted) Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("درخواست تغییر چراغ‌ها با مشکل مواجه شد")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("منابع و مخازن"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "بروزرسانی",
            onPressed: _fetchAndSaveDeviceData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _relayList.isEmpty && _stackList.isEmpty
          ? const Center(child: Text("داده‌ای برای نمایش وجود ندارد"))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView(
                children: [
                  // ====== بخش مخازن ======
                  const Text(
                    "مخازن",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _stackList.isEmpty
                      ? const Center(
                          child: Text(
                            "داده‌ای برای نمایش وجود ندارد",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : SizedBox(
                          height: 180,
                          child: Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(
                                  tanks.length,
                                  (i) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: _buildTankCircle(
                                      "مخزن ${i + 1}",
                                      tanks[i],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 24),

                  // ====== بخش چراغ‌ها ======
                  const Text(
                    "چراغ‌ها",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _relayList.isEmpty
                      ? const Center(
                          child: Text(
                            "داده‌ای برای نمایش وجود ندارد",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Column(
                          children: List.generate(
                            relays.length,
                            (index) => _buildRelayTile(index),
                          ),
                        ),

                  const SizedBox(height: 24),

                  // ====== دکمه‌ها ======
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('انصراف'),
                      ),
                      ElevatedButton(
                        onPressed: _relayList.isEmpty || _saveIsSubmitting
                            ? null
                            : _submitRelay,
                        child: _saveIsSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                ),
                              )
                            : const Text('ثبت'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
