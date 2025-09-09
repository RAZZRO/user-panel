import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:user_panel/models/Information_model.dart';

class DeviceDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'central_data.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
    CREATE TABLE central_data(
      identifier INTEGER PRIMARY KEY,
      deviceName TEXT,
      batteryCharge INTEGER,
      simCharge INTEGER,
      internet TEXT,
      rain BOOL,
      windDirection TEXT,
      timestamp TEXT
    )
  ''');

        await db.execute('''
          CREATE TABLE irrigation_data(
            irrigationId INTEGER PRIMARY KEY,
            deviceId TEXT,
            rtuId TEXT,
            mode TEXT,
            status TEXT,
            startDate TEXT,
            stopDate TEXT,
            duration INTEGER,
            timestamp TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE rtu_data(
            rtuDataId INTEGER PRIMARY KEY,
            deviceId TEXT,
            rtuId TEXT,
            humidity INTEGER,
            airTemperature TEXT,
            moisture INTEGER,
            ph TEXT,
            ec INTEGER,
            co2 INTEGER,
            soilTemperature INTEGER,
            timestamp TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<void> insertDevice(DeviceInfo device) async {
    // print(device);
    final db = await database;
    await db.insert(
      'central_data',
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('save done');
  }

  static Future<DeviceInfo?> getDevice(int identifier) async {
    print("start extracting device");
    final db = await database;
    final res = await db.query(
      'central_data',
      where: 'identifier = ?',
      whereArgs: [identifier],
    );
    print(res);
    if (res.isNotEmpty) {
      return DeviceInfo.fromMap(res.last);
    }
    return null;
  }

  static Future<void> insertIrrigation(IrrigationData data) async {
    final db = await database;
    await db.insert(
      'irrigation_data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<IrrigationData>> getIrrigationData(String deviceId) async {
    final db = await database;
    final res = await db.query(
      'irrigation_data',
      where: 'deviceId = ?',
      whereArgs: [deviceId],
    );
    return res.map((e) => IrrigationData.fromJson(e)).toList();
  }

  static Future<void> insertRtu(RtuData data) async {
    final db = await database;
    await db.insert(
      'rtu_data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<RtuData>> getRtuData(String deviceId) async {
    final db = await database;
    final res = await db.query(
      'rtu_data',
      where: 'deviceId = ?',
      whereArgs: [deviceId],
    );
    return res.map((e) => RtuData.fromJson(e)).toList();
  }
}
