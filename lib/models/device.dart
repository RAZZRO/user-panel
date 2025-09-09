class Device {
  final String name;
  final String identifier;
  final String registerDate;

  Device({
    required this.name,
    required this.identifier,
    required this.registerDate,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      name: json['name'],
      identifier: json['identifier'],
      registerDate: json['start_date'],
    );
  }
}
