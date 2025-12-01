//import 'dart:math';

//import 'dart:math';

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
  final int deviceId;
  final String? rtuId;
  final String? mode;
  final String? status;
  final String? startDate;
  final String? stopDate;
  final int? duration;
  final String? timestamp;

  IrrigationData({
    required this.irrigationId,
    required this.deviceId,
    this.rtuId,
    this.mode,
    this.status,
    this.startDate,
    this.stopDate,
    this.duration,
    this.timestamp,
  });

  factory IrrigationData.fromJson(Map<String, dynamic> json) {
    int irrigationId = json['irrigation_id'] is String
        ? int.parse(json['irrigation_id'])
        : json['irrigation_id'];

    int deviceId = json['irrigation_device_id'] is String
        ? int.parse(json['irrigation_device_id'])
        : json['irrigation_device_id'];

    String? rtuId = json['irrigation_rtu_id']?.toString();
    String? mode = json['irrigation_mode']?.toString();
    String? status = json['irrigation_status']?.toString();
    String? startDate = json['irrigation_start_date']?.toString();
    String? stopDate = json['irrigation_stop_date']?.toString();

    int? duration = json['irrigation_duration'] == null
        ? null
        : (json['irrigation_duration'] is String
              ? int.tryParse(json['irrigation_duration'])
              : json['irrigation_duration']);

    String? timestamp = json['irrigation_timestamp']?.toString();

    return IrrigationData(
      irrigationId: irrigationId,
      deviceId: deviceId,
      rtuId: rtuId,
      mode: mode,
      status: status,
      startDate: startDate,
      stopDate: stopDate,
      duration: duration,
      timestamp: timestamp,
    );
  }

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

  factory IrrigationData.fromMap(Map<String, dynamic> map) => IrrigationData(
    irrigationId: map['irrigationId'] is String
        ? int.parse(map['irrigationId'])
        : map['irrigationId'],
    deviceId: map['deviceId'] is String
        ? int.parse(map['deviceId'])
        : map['deviceId'],
    rtuId: map['rtuId']?.toString(),
    mode: map['mode']?.toString(),
    status: map['status']?.toString(),
    startDate: map['startDate']?.toString(),
    stopDate: map['stopDate']?.toString(),
    duration: map['duration'] == null
        ? null
        : (map['duration'] is String
              ? int.tryParse(map['duration'])
              : map['duration']),
    timestamp: map['timestamp']?.toString(),
  );
}

class RtuData {
  final int rtuDataId;
  final int deviceId;
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
    required this.deviceId,
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

  factory RtuData.fromJson(Map<String, dynamic> json) {
    int rtuDataId = json['rtu_data_id'] is String
        ? int.parse(json['rtu_data_id'])
        : json['rtu_data_id'];

    int deviceId = json['rtu_device_id'] is String
        ? int.parse(json['rtu_device_id'])
        : json['rtu_device_id'];

    String? rtuId = json['rtu_rtu_id']?.toString();

    int? humidity = json['rtu_humidity'] == null
        ? null
        : (json['rtu_humidity'] is String
            ? int.tryParse(json['rtu_humidity'])
            : json['rtu_humidity']);

    String? airTemperature = json['rtu_airtemperature']?.toString();

    int? moisture = json['rtu_moisture'] == null
        ? null
        : (json['rtu_moisture'] is String
            ? int.tryParse(json['rtu_moisture'])
            : json['rtu_moisture']);

    String? ph = json['rtu_ph']?.toString();

    int? ec = json['rtu_ec'] == null
        ? null
        : (json['rtu_ec'] is String ? int.tryParse(json['rtu_ec']) : json['rtu_ec']);

    int? co2 = json['rtu_co2'] == null
        ? null
        : (json['rtu_co2'] is String ? int.tryParse(json['rtu_co2']) : json['rtu_co2']);

    int? soilTemperature = json['rtu_soiltemperature'] == null
        ? null
        : (json['rtu_soiltemperature'] is String
            ? int.tryParse(json['rtu_soiltemperature'])
            : json['rtu_soiltemperature']);

    String? timestamp = json['rtu_timestamp']?.toString();

    return RtuData(
      rtuDataId: rtuDataId,
      deviceId: deviceId,
      rtuId: rtuId,
      humidity: humidity,
      airTemperature: airTemperature,
      moisture: moisture,
      ph: ph,
      ec: ec,
      co2: co2,
      soilTemperature: soilTemperature,
      timestamp: timestamp,
    );
  }

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

  factory RtuData.fromMap(Map<String, dynamic> map) => RtuData(
        rtuDataId: map['rtuDataId'] is String
            ? int.parse(map['rtuDataId'])
            : map['rtuDataId'],
        deviceId: map['deviceId'] is String
            ? int.parse(map['deviceId'])
            : map['deviceId'],
        rtuId: map['rtuId']?.toString(),
        humidity: map['humidity'] is String
            ? int.tryParse(map['humidity'])
            : map['humidity'],
        airTemperature: map['airTemperature']?.toString(),
        moisture: map['moisture'] is String
            ? int.tryParse(map['moisture'])
            : map['moisture'],
        ph: map['ph']?.toString(),
        ec: map['ec'] is String ? int.tryParse(map['ec']) : map['ec'],
        co2: map['co2'] is String ? int.tryParse(map['co2']) : map['co2'],
        soilTemperature: map['soilTemperature'] is String
            ? int.tryParse(map['soilTemperature'])
            : map['soilTemperature'],
        timestamp: map['timestamp']?.toString(),
      );
}

class StackData {
  final int stackDataId;
  final int deviceId;
  final int? tankId;
  final int? wLevel;
  final int? electricityLevel;
  final String? phLevel;
  final String? timestamp;

  StackData({
    required this.stackDataId,
    required this.deviceId,
    this.tankId,
    this.wLevel,
    this.electricityLevel,
    this.phLevel,
    this.timestamp,
  });

  factory StackData.fromJson(Map<String, dynamic> json) {
    int stackDataId = json['stack_id'] is String
        ? int.parse(json['stack_id'])
        : json['stack_id'];

    int deviceId = json['stack_device_id'] is String
        ? int.parse(json['stack_device_id'])
        : json['stack_device_id'];

    int? tankId = json['stack_stack_id'] == null
        ? null
        : (json['stack_stack_id'] is String
            ? int.tryParse(json['stack_stack_id'])
            : json['stack_stack_id']);

    int? wLevel = json['stack_w_level'] is String
        ? int.tryParse(json['stack_w_level'])
        : json['stack_w_level'];

    int? electricityLevel = json['stack_electricity_level'] is String
        ? int.tryParse(json['stack_electricity_level'])
        : json['stack_electricity_level'];

    String? phLevel = json['stack_ph_level']?.toString();
    String? timestamp = json['stack_timestamp']?.toString();

    return StackData(
      stackDataId: stackDataId,
      deviceId: deviceId,
      tankId: tankId,
      wLevel: wLevel,
      electricityLevel: electricityLevel,
      phLevel: phLevel,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
        'stackDataId': stackDataId,
        'deviceId': deviceId,
        'tankId': tankId,
        'wLevel': wLevel,
        'electricityLevel': electricityLevel,
        'phLevel': phLevel,
        'timestamp': timestamp,
      };

  factory StackData.fromMap(Map<String, dynamic> map) => StackData(
        stackDataId: map['stackDataId'] is String
            ? int.parse(map['stackDataId'])
            : map['stackDataId'],
        deviceId: map['deviceId'] is String
            ? int.parse(map['deviceId'])
            : map['deviceId'],
        tankId: map['tankId'] is String
            ? int.tryParse(map['tankId'])
            : map['tankId'],
        wLevel: map['wLevel'] is String
            ? int.tryParse(map['wLevel'])
            : map['wLevel'],
        electricityLevel: map['electricityLevel'] is String
            ? int.tryParse(map['electricityLevel'])
            : map['electricityLevel'],
        phLevel: map['phLevel']?.toString(),
        timestamp: map['timestamp']?.toString(),
      );
}
class RelayData {
  final int relayDataId;
  final int deviceId;
  final int? relayId;
  final bool? state;
  final String? status;
  final String? timestamp;

  RelayData({
    required this.relayDataId,
    required this.deviceId,
    this.relayId,
    this.state,
    this.status,
    this.timestamp,
  });

  factory RelayData.fromJson(Map<String, dynamic> json) {
    int relayDataId = json['relay_id'] is String
        ? int.parse(json['relay_id'])
        : json['relay_id'];

    int deviceId = json['relay_device_id'] is String
        ? int.parse(json['relay_device_id'])
        : json['relay_device_id'];

    int? relayId = json['relay_relay_id'] == null
        ? null
        : (json['relay_relay_id'] is String
            ? int.tryParse(json['relay_relay_id'])
            : json['relay_relay_id']);

    // state می‌تونه bool یا int یا حتی string باشه
    bool? state;
    final rawState = json['relay_state'];
    if (rawState is bool) {
      state = rawState;
    } else if (rawState is int) {
      state = rawState == 1;
    } else if (rawState is String) {
      state = rawState == 'true' || rawState == '1';
    }

    String? status = json['relay_message_status']?.toString();
    String? timestamp = json['relay_timestamp']?.toString();

    return RelayData(
      relayDataId: relayDataId,
      deviceId: deviceId,
      relayId: relayId,
      state: state,
      status: status,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
        'relayDataId': relayDataId,
        'deviceId': deviceId,
        'relayId': relayId,
        'state': state == true ? 1 : 0,
        'status': status,
        'timestamp': timestamp,
      };

  factory RelayData.fromMap(Map<String, dynamic> map) => RelayData(
        relayDataId: map['relayDataId'] is String
            ? int.parse(map['relayDataId'])
            : map['relayDataId'],
        deviceId: map['deviceId'] is String
            ? int.parse(map['deviceId'])
            : map['deviceId'],
        relayId: map['relayId'] is String
            ? int.tryParse(map['relayId'])
            : map['relayId'],
        state: map['state'] == 1 ||
            map['state'] == true ||
            map['state'] == '1' ||
            map['state'] == 'true',
        status: map['status']?.toString(),
        timestamp: map['timestamp']?.toString(),
      );
}
