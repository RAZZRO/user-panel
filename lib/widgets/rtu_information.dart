import 'package:flutter/material.dart';

class RtuInformation extends StatelessWidget {
  final Map<String, dynamic> unitData;

  const RtuInformation({super.key, required this.unitData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("جزئیات واحد ${unitData["unit"]}"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.water_drop, color: Colors.lightBlue),
            title: const Text("رطوبت"),
            subtitle: Text("${unitData["humidity"]}%"),
          ),
          ListTile(
            leading: const Icon(Icons.wb_sunny, color: Colors.orange),
            title: const Text("دمای هوا"),
            subtitle: Text("${unitData["airTemp"]} °C"),
          ),
          ListTile(
            leading: const Icon(Icons.thermostat, color: Colors.brown),
            title: const Text("دمای خاک"),
            subtitle: Text("${unitData["soilTemp"]} °C"),
          ),
          ListTile(
            leading: const Icon(Icons.science, color: Colors.green),
            title: const Text("pH"),
            subtitle: Text(unitData["ph"].toString()),
          ),
          ListTile(
            leading: const Icon(Icons.bolt, color: Colors.deepPurple),
            title: const Text("EC"),
            subtitle: Text("${unitData["ec"]} mS/cm"),
          ),
          ListTile(
            leading: const Icon(Icons.cloud, color: Colors.grey),
            title: const Text("CO₂"),
            subtitle: Text("${unitData["co2"]} ppm"),
          ),
          ListTile(
            leading: const Icon(Icons.update, color: Colors.black),
            title: const Text("آخرین بروزرسانی"),
            subtitle: Text(unitData["timestamp"].toString()),
          ),
        ],
      ),
    );
  }
}
