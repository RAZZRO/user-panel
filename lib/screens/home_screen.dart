import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_panel/screens/irrigation_screen.dart';
//import 'package:user_panel/models/device.dart';
import 'package:user_panel/screens/login_screen.dart';
import 'package:user_panel/screens/device_information.dart';
import 'package:user_panel/models/menu.dart';
import 'package:user_panel/screens/messages_screen.dart';
import 'package:user_panel/screens/resources_screen.dart';
import 'package:user_panel/screens/rtu_screen.dart';
import 'package:user_panel/screens/user_information.dart';
import 'package:user_panel/widgets/Device_status_card.dart';
import 'package:user_panel/widgets/menu_grid_item.dart';
import 'package:user_panel/screens/device_list_screen.dart ';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_panel/models/Information_model.dart';
import 'package:user_panel/services/sqlite_database.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? selectedDeviceIdentifier;
  DeviceInfo? selectedDevice;

  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }

  Future<void> _loadDeviceData() async {
    final prefs = await SharedPreferences.getInstance();

    final _selectedDeviceIdentifier =
        prefs.getString('selected_device_identifier');

    selectedDeviceIdentifier = _selectedDeviceIdentifier;
    print(selectedDeviceIdentifier);
    if (selectedDeviceIdentifier != null) {
      print("device id select");
      final cached =
          await DeviceDatabase.getDevice(int.parse(_selectedDeviceIdentifier!));
      if (cached != null) {
        selectedDevice = cached;
        setState(() {
          selectedDevice = cached;
        });
      }
      print('device information is ready');
      if (selectedDevice?.identifier != null) {
        print(selectedDevice!.identifier);
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأیید خروج'),
        content: const Text('آیا از خارج شدن از حساب کاربری اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('خیر'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('بله'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.setBool('isLoggedIn', false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void selectItem(BuildContext context, MenuItem item) {
    ScaffoldMessenger.of(context).clearSnackBars();

    switch (item) {
      case MenuItem.deviceList:
        showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (context) => const UserDevicesScreen(),
        ).then((result) {
          if (result == true) {
            print("come load device");
            _loadDeviceData();
          }
        });
        break;

      case MenuItem.editInfo:
        showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (context) => const EditUserScreen(),
        );
        break;
      case MenuItem.messages:
        showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (context) => const MessageScreen(),
        );
        break;
      case MenuItem.deviceInformation:
        showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (context) => const EditDeviceScreen(),
        ).then((result) {
          if (result == true) {
            print("come load device");
            _loadDeviceData();
          }
        });
        break;
      case MenuItem.rtus:
              showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (context) => const RtuScreen(),
        );
        break;
      case MenuItem.relaies:
              showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (context) => const ResourcesScreen(),
        );
        break;
      case MenuItem.irrigation:
        showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (context) => const IrrigationScreen(),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.center,
          child: Text("پنل مدیریت گلخانه"),
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          if (selectedDevice != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: DeviceStatusCard(device: selectedDevice!),
            ),
          Padding(
            //padding: const EdgeInsets.only(left: 10,bottom: 20,right: 20,top: 0),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // if (selectedDevice != null)
                  //   DeviceStatusCard(
                  //     device: selectedDevice!,
                  //   ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 35,
                    mainAxisSpacing: 5,
                    children: [
                      for (final item in MenuItem.values)
                        MenuGridItem(
                          item: item,
                          onSelectedItem: () {
                            selectItem(context, item);
                          },
                        )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
