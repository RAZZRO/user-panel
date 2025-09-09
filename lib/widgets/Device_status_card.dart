import 'package:flutter/material.dart';
import 'package:user_panel/models/Information_model.dart';

class DeviceStatusCard extends StatelessWidget {
  const DeviceStatusCard({super.key, required this.device});
  final DeviceInfo device;

  @override
  Widget build(BuildContext context) {
    final String deviceName = device.deviceName ?? "";
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    IconData getBatteryIcon(int charge) {
      if (charge < 20) return Icons.battery_alert;
      if (charge < 50) return Icons.battery_3_bar;
      if (charge < 80) return Icons.battery_5_bar;
      return Icons.battery_full;
    }

    Color getBatteryColor(int charge) {
      print(isDarkMode);
      if (charge < 20) return Colors.red;
      if (charge < 50) {
        if (isDarkMode) {
          return Color.fromARGB(255, 222, 222, 35);
        } else {
          return Color.fromARGB(255, 172, 172, 32);
        }
      }
      return Colors.green;
    }

    Widget buildStatusBox({
      required IconData icon,
      required String value,
      required Color color,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.transparent, // حذف رنگ بک‌گراند
            borderRadius: BorderRadius.circular(50), // حداکثر گردی
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            textDirection: TextDirection.rtl, // راست‌چین
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(fontSize: 14, color: color),
              ),
            ],
          ),
        ),
      );
    }

    final int batteryCharge = device.batteryCharge ?? 0;
    final batteryColor = getBatteryColor(batteryCharge);
    final batteryIcon = getBatteryIcon(batteryCharge);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 🔷 کادر نام دستگاه با همان استایل
        Row(
          children: [
            buildStatusBox(
              icon: Icons.devices,
              value: deviceName.isNotEmpty ? deviceName : "بدون‌نام",
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 🔷 کادرهای وضعیت
        Row(
          children: [
            if (device.batteryCharge != null)
              buildStatusBox(
                icon: batteryIcon,
                value: "${device.batteryCharge}%",
                color: batteryColor,
              ),
              if(device.simCharge != null)
            buildStatusBox(
              icon: Icons.sim_card,
              value: device.simCharge.toString(),
              color: Colors.blue,
            ),
            if(device.internet != null )
            buildStatusBox(
              icon: Icons.network_check,
              value: device.internet!,
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }
}
