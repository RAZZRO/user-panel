import 'package:flutter/material.dart';
import 'package:user_panel/services/api_service.dart';
import 'package:user_panel/models/device.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDevicesScreen extends StatefulWidget {
  const UserDevicesScreen({super.key});

  @override
  State<UserDevicesScreen> createState() => _UserDevicesScreenState();
}

class _UserDevicesScreenState extends State<UserDevicesScreen> {
  List<Device> devices = [];
  String? selectedIdentifier;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedIdentifier();
    _fetchDevicesFromBackend();
  }

  Future<void> _loadSelectedIdentifier() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedIdentifier = prefs.getString('selected_device_identifier');
    });
  }

  Future<void> _saveSelectedIdentifier(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_device_identifier', identifier);
  }

  Future<void> _fetchDevicesFromBackend() async {
    setState(() {
      _isLoading = true;
    });

    try {
      const url = 'all_topics';
      final result = await ApiService.getRequest(url);

      if (result['success'] == true) {
        final List<dynamic> listData = result['data'];
        setState(() {
          devices = listData
              .map<Device>((device) => Device(
                    name: device["device_name"],
                    identifier: device['identifier'].toString(),
                    registerDate: device['start_date'].toString(),
                  ))
              .toList();
        });
      } else {
        // می‌تونی خطاهای بیشتر هم اینجا مدیریت کنی
        _showDialog('خطا', 'دریافت دستگاه‌ها با مشکل مواجه شد.');
      }
    } catch (e) {
      _showDialog('خطا', 'خطا در ارتباط با سرور: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      appBar: AppBar(title: const Text('لیست دستگاه‌ها')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : devices.isEmpty
              ? const Center(child: Text('هیچ دستگاهی پیدا نشد'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedIdentifier =
                                      devices[index].identifier;
                                });
                              },
                              child: ListTile(
                                title: Text(device.name.isNotEmpty
                                    ? device.name
                                    : 'بدون نام'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('شناسه: ${device.identifier}'),
                                    Text(
                                        'تاریخ ثبت‌نام: ${device.registerDate}'),
                                  ],
                                ),
                                leading: Radio<String>(
                                  value: device.identifier,
                                  groupValue: selectedIdentifier,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedIdentifier = value;
                                    });
                                  },
                                ),
                                // trailing حذف شد (آیکون ویرایش)
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: selectedIdentifier == null || _isSaving
                                  ? null
                                  : () async {
                                      setState(() {
                                        _isSaving = true;
                                      });

                                      try {
                                        await _saveSelectedIdentifier(
                                            selectedIdentifier!);

                                        if (!mounted) return;

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('دستگاه ذخیره شد'),
                                          ),
                                        );
                                        Navigator.pop(context, true);
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(content: Text('خطا: $e')),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _isSaving = false;
                                          });
                                        }
                                      }
                                    },
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('ثبت'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text('لغو'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
