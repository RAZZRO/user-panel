import 'package:flutter/material.dart';
import 'package:user_panel/services/sqlite_database.dart';
import 'package:user_panel/models/Information_model.dart';

class RtuInformation extends StatefulWidget {
  final int deviceId;
  final String rtuId;

  const RtuInformation({
    super.key,
    required this.deviceId,
    required this.rtuId,
  });

  @override
  State<RtuInformation> createState() => _RtuInformationState();
}

class _RtuInformationState extends State<RtuInformation> {
  List<RtuData> _rtuList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  /// دریافت داده‌های RTU از دیتابیس محلی
  Future<void> _loadStoredData() async {
    setState(() => _isLoading = true);
    final rtuList = await DeviceDatabase.getRtuData(widget.deviceId);

    setState(() {
      _rtuList = rtuList;
      _isLoading = false;
    });

    print("=== RTU Data loaded ===");
    for (var item in rtuList) {
      print(item.toMap());
    }
  }

  /// ویجت کمکی برای نمایش هر آیتم، فقط وقتی مقدارش null نیست
  Widget _buildListTile({
    required IconData icon,
    required Color color,
    required String title,
    required String? value,
    String? unit,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    // اطمینان از اینکه واحد اندازه‌گیری همیشه بعد از مقدار بیاد (راست متن)
    final displayText = unit != null ? "$value $unit" : value;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(displayText, textDirection: TextDirection.ltr),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _rtuList.where(
      (item) => item.rtuId.toString() == widget.rtuId,
    );
    final data = filtered.isNotEmpty ? filtered.first : null;
    print(data);

    return Scaffold(
      appBar: AppBar(
        title: Text("جزئیات واحد ${widget.rtuId}"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (data == null)
          ? const Center(child: Text("داده‌ای برای نمایش وجود ندارد"))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildListTile(
                  icon: Icons.water_drop,
                  color: Colors.lightBlue,
                  title: "رطوبت",
                  value: data.humidity?.toString(),
                  unit: "%",
                ),
                _buildListTile(
                  icon: Icons.wb_sunny,
                  color: Colors.orange,
                  title: "دمای هوا",
                  value: data.airTemperature?.toString(),
                  unit: "°C",
                ),
                _buildListTile(
                  icon: Icons.thermostat,
                  color: Colors.brown,
                  title: "دمای خاک",
                  value: data.soilTemperature?.toString(),
                  unit: "°C",
                ),
                _buildListTile(
                  icon: Icons.science,
                  color: Colors.green,
                  title: "pH",
                  value: data.ph?.toString(),
                ),
                _buildListTile(
                  icon: Icons.bolt,
                  color: Colors.deepPurple,
                  title: "EC",
                  value: data.ec?.toString(),
                  unit: "mS/cm",
                ),
                _buildListTile(
                  icon: Icons.cloud,
                  color: Colors.grey,
                  title: "CO₂",
                  value: data.co2?.toString(),
                  unit: "ppm",
                ),
                _buildListTile(
                  icon: Icons.update,
                  color: const Color.fromARGB(255, 76, 118, 59),
                  title: "آخرین بروزرسانی",
                  value: data.timestamp,
                ),
              ],
            ),
    );
  }
}
