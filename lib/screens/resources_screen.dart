import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_panel/models/Information_model.dart';
import 'package:user_panel/services/api_service.dart';
import 'package:user_panel/services/sqlite_database.dart';

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

  // // شبیه‌سازی داده‌ها
  // = [75, 15]; // درصد مخزن 1 و 2
  // List<bool> relays = [true, false, true, false, true]; // وضعیت رله‌ها

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

  /// ویجت دایره‌ای مخزن با انیمیشن
  Widget _buildTankCircle(String name, double level) {
    final color = getTankColor(level);
    return Column(
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
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  /// ویجت رله
  Widget _buildRelayTile(int index) {
    return Card(
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

    final result = await ApiService.postRequest('stack_information', {
      'deviceId': selectedDeviceIdentifier,
    });

    print(result);

    if (result['data'] is List) {
      final data = result['data'] as List;
      for (final row in data) {
        if (row['stack_id'] == null) continue;
        final stack = StackData.fromJson(row);
        print('StackData.fromJson(row)');
        await DeviceDatabase.insertStack(stack);
        print('insertStack(stack)');

        if (row['relay_id'] == null) continue;
        final relay = RelayData.fromJson(row);
        print('RelayData.fromJson(row)');
        await DeviceDatabase.insertRelay(relay);
        print('insertRelay(relay)');
      }
    }

    await _loadStoredData();

    setState(() {
      _isLoading = false;
    });
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
    stackList.sort(
      (a, b) => (a.tankId.toString()).compareTo(b.tankId.toString()),
    );

    final relayList = await DeviceDatabase.getRelayData(
      int.parse(selectedDeviceIdentifier),
    );
    relayList.sort(
      (a, b) => (a.relayId.toString()).compareTo(b.relayId.toString()),
    );

    // استخراج درصد مخازن
    final loadedTanks = stackList.map((s) {
      // فرض بر این است که در StackData فیلد waterLevel یا مشابه آن داری
      // اگر فیلد دیگری است (مثل wLevel)، همان را بگذار
      return s.wLevel?.toDouble() ?? 0.0;
    }).toList();

    // استخراج وضعیت رله‌ها
    final loadedRelays = relayList.map((r) {
      // فرض بر این است که در RelayData فیلد state از نوع bool داری
      return r.state ?? false;
    }).toList();

    setState(() {
      _stackList = stackList;
      _relayList = relayList;
      tanks = loadedTanks;
      relays = loadedRelays;
    });

    print("=== Irrigation Data loaded ===");
    for (var item in stackList) {
      print(item.toMap());
    }
    for (var item in relayList) {
      print(item.toMap());
    }
  }

  /// ارسال داده‌ها به سرور (شبیه‌سازی)
  void _submitData() async {
    setState(() => _saveIsSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _saveIsSubmitting = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("داده‌ها ثبت شد")));
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
            onPressed: () async {
              await _fetchAndSaveDeviceData();
            },
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
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            tanks.length,
                            (i) => _buildTankCircle("مخزن ${i + 1}", tanks[i]),
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
                        // فقط وقتی رله‌ها موجود هستند، دکمه فعال شود
                        onPressed: _relayList.isEmpty
                            ? null
                            : _saveIsSubmitting
                            ? null
                            : _submitData,
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
