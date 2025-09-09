import 'package:flutter/material.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  bool _saveIsSubmitting = false;

  // شبیه‌سازی داده‌ها
  List<double> tanks = [75, 15]; // درصد مخزن 1 و 2
  List<bool> relays = [true, false, true, false, true]; // وضعیت رله‌ها

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

  /// ارسال داده‌ها به سرور (شبیه‌سازی)
  void _submitData() async {
    setState(() => _saveIsSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _saveIsSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("داده‌ها ثبت شد")),
    );
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("در حال بروزرسانی داده‌ها...")),
              );
              // اینجا بعداً API فراخوانی کن
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            const Text(
              "مخازن",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTankCircle("مخزن 1", tanks[0]),
                _buildTankCircle("مخزن 2", tanks[1]),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "چراغ ها",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Column(
              children: List.generate(relays.length, (index) => _buildRelayTile(index)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('انصراف'),
                ),
                ElevatedButton(
                  onPressed: _saveIsSubmitting ? null : _submitData,
                  child: _saveIsSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
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
