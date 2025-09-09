class DeviceInfo {
  final int identifier;
  final String? deviceName;
  final int? batteryCharge;
  final int? simCharge;
  final String? internet;
  final bool? rain;
  final String? windDirection;
  final String? timestamp;

  DeviceInfo({
    required this.identifier,
    this.deviceName,
    this.batteryCharge,
    this.simCharge,
    this.internet,
    this.rain,
    this.windDirection,
    this.timestamp,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    int identifier = int.parse(json['device_identifier']);
    String? deviceName = json['device_name'];
    int? batteryCharge = json['battery_charge'];
    int? simCharge = json['sim_charge'];
    String? internet = json['internet'];
    bool? rain = json['rain'];
    String? windDirection = json['wind_direction'];
    String? timestamp = json['latest_timestamp'];

    return DeviceInfo(
      identifier: identifier,
      deviceName: deviceName,
      batteryCharge: batteryCharge,
      simCharge: simCharge,
      internet: internet,
      rain: rain,
      windDirection: windDirection,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
        'identifier': identifier,
        'deviceName': deviceName,
        'batteryCharge': batteryCharge,
        'simCharge': simCharge,
        'internet': internet,
        'rain': rain == true ? 1 : 0,
        'windDirection': windDirection,
        'timestamp': timestamp,
      };

  factory DeviceInfo.fromMap(Map<String, dynamic> map) => DeviceInfo(
        identifier: map['identifier'],
        deviceName: map['deviceName'],
        batteryCharge: map['batteryCharge'],
        simCharge: map['simCharge'],
        internet: map['internet'],
        rain: map['rain'] == 1 || map['rain'] == true,
        windDirection: map['windDirection'],
        timestamp: map['timestamp'],
      );
}
class IrrigationData {
  final int irrigationId;
  final String? deviceId;
  final String? rtuId;
  final String? mode;
  final String? status;
  final String? startDate;
  final String? stopDate;
  final int? duration;
  final String? timestamp;

  IrrigationData({
    required this.irrigationId,
    this.deviceId,
    this.rtuId,
    this.mode,
    this.status,
    this.startDate,
    this.stopDate,
    this.duration,
    this.timestamp,
  });

  factory IrrigationData.fromJson(Map<String, dynamic> json) => IrrigationData(
        irrigationId: json['irrigation_id'],
        deviceId: json['irrigation_device_id'],
        rtuId: json['irrigation_rtu_id'],
        mode: json['irrigation_mode'],
        status: json['irrigation_status'],
        startDate: json['irrigation_start_date'],
        stopDate: json['irrigation_stop_date'],
        duration: json['irrigation_duration'],
        timestamp: json['irrigation_timestamp'],
      );

  Map<String, dynamic> toMap() => {
        'irrigationId': irrigationId,
        'deviceId': deviceId,
        'rtuId': rtuId,
        'mode': mode,
        'status': status,
        'startDate': startDate,
        'stopDate': stopDate,
        'duration': duration,
        'timestamp': timestamp,
      };
}
class RtuData {
  final int rtuDataId;
  final String? deviceId;
  final String? rtuId;
  final int? humidity;
  final String? airTemperature;
  final int? moisture;
  final String? ph;
  final int? ec;
  final int? co2;
  final int? soilTemperature;
  final String? timestamp;

  RtuData({
    required this.rtuDataId,
    this.deviceId,
    this.rtuId,
    this.humidity,
    this.airTemperature,
    this.moisture,
    this.ph,
    this.ec,
    this.co2,
    this.soilTemperature,
    this.timestamp,
  });

  factory RtuData.fromJson(Map<String, dynamic> json) => RtuData(
        rtuDataId: json['rtu_data_id'],
        deviceId: json['rtu_device_id'],
        rtuId: json['rtu_rtu_id'],
        humidity: json['rtu_humidity'],
        airTemperature: json['rtu_airtemperature'],
        moisture: json['rtu_moisture'],
        ph: json['rtu_ph'],
        ec: json['rtu_ec'],
        co2: json['rtu_co2'],
        soilTemperature: json['rtu_soiltemperature'],
        timestamp: json['rtu_timestamp'],
      );

  Map<String, dynamic> toMap() => {
        'rtuDataId': rtuDataId,
        'deviceId': deviceId,
        'rtuId': rtuId,
        'humidity': humidity,
        'airTemperature': airTemperature,
        'moisture': moisture,
        'ph': ph,
        'ec': ec,
        'co2': co2,
        'soilTemperature': soilTemperature,
        'timestamp': timestamp,
      };
}
