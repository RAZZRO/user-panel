import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:user_panel/models/Information_model.dart';

class DeviceDatabase {
  static Database? _db;

  /// گرفتن دیتابیس، ایجاد در صورت عدم وجود
  static Future<Database> get database async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'central_data.db');

    // فقط برای ریست اولیه دیتابیس (یک بار اجرا شود)
    // await deleteDatabase(path);
    print('📂 Database path: $path');

    _db = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        print('🛠 Creating tables in new database...');
        await _createTables(db);
      },
      onOpen: (db) async {
        print('✅ Database opened');
        // بررسی وجود جداول (ایجاد در صورت نبود)
        await _checkAndCreateTables(db);
      },
    );

    return _db!;
  }

  /// ایجاد جداول
  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS central_data(
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
    print('📋 central_data table created');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS irrigation_data(
        irrigationId INTEGER PRIMARY KEY,
        deviceId INTEGER,
        rtuId TEXT,
        mode TEXT,
        status TEXT,
        startDate TEXT,
        stopDate TEXT,
        duration INTEGER,
        timestamp TEXT
      )
    ''');
    print('📋 irrigation_data table created');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS rtu_data(
        rtuDataId INTEGER PRIMARY KEY,
        deviceId INTEGER,
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
    print('📋 rtu_data table created');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS stack_data(
        stackDataId INTEGER PRIMARY KEY,
        deviceId INTEGER,
        tankId INTEGER,
        wLevel INTEGER,
        electricityLevel INTEGER,
        phLevel TEXT,
        timestamp TEXT
      )
    ''');
    print('📋 stack_data table created');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS relay_data(
        relayDataId INTEGER PRIMARY KEY,
        deviceId INTEGER,
        relayId INTEGER,
        state BOOL,
        status TEXT,
        timestamp TEXT
      )
    ''');
    print('📋 relay_data table created');
  }

  /// بررسی و ایجاد جداول در صورت نبود
  static Future<void> _checkAndCreateTables(Database db) async {
    print('🔍 Checking tables...');
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table';",
    );

    final existingTables = tables.map((t) => t['name'] as String).toSet();
    print('📋 Tables in DB: $existingTables');

    final requiredTables = {
      'central_data',
      'irrigation_data',
      'rtu_data',
      'stack_data',
      'relay_data',
    };

    final missingTables = requiredTables.difference(existingTables);

    if (missingTables.isNotEmpty) {
      print('⚠️ Missing tables detected: $missingTables');
      await _createTables(db);
    } else {
      print('✅ All tables exist');
    }
  }

  static Future<void> clearAllData() async {
    final path = join(await getDatabasesPath(), 'central_data.db');
    await deleteDatabase(path);
    _db = null;
    print('🧹 All local SQLite data cleared.');
  }

  /// ذخیره Device
  static Future<void> insertDevice(DeviceInfo device) async {
    final db = await database;
    final id = await db.insert(
      'central_data',
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('💾 Device inserted with id: $id');
  }

  /// دریافت Device
  static Future<DeviceInfo?> getDevice(int identifier) async {
    print('🔍 Searching for device with identifier = $identifier');
    final db = await database;
    final res = await db.query(
      'central_data',
      where: 'identifier = ?',
      whereArgs: [identifier],
    );
    print('Query result: $res');
    if (res.isNotEmpty) return DeviceInfo.fromMap(res.last);
    return null;
  }

  /// ذخیره IrrigationData
  static Future<void> insertIrrigation(IrrigationData data) async {
    final db = await database;
    final id = await db.insert(
      'irrigation_data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('💾 Irrigation inserted with irrigationId: $id');

    final all = await db.query('irrigation_data');
    print('📋 All rows in irrigation_data: $all');
  }

  /// دریافت IrrigationData بر اساس deviceId
  static Future<List<IrrigationData>> getIrrigationData(int deviceId) async {
    final db = await database;
    // await db.delete('irrigation_data');

    final res = await db.rawQuery(
      '''
    SELECT ir.*
    FROM irrigation_data ir
    INNER JOIN (
      SELECT rtuId, MAX(irrigationId) AS latestId
      FROM irrigation_data
      WHERE deviceId = ?
      GROUP BY rtuId
    ) latest
    ON ir.rtuId = latest.rtuId AND ir.irrigationId = latest.latestId
    WHERE ir.deviceId = ?
    ORDER BY ir.rtuId;
  ''',
      [deviceId, deviceId],
    );

    print('✅ Filtered latest irrigation_data rows by unique rtuId: $res');

    return res.map((e) => IrrigationData.fromMap(e)).toList();
  }

  /// ذخیره RtuData
  static Future<void> insertRtu(RtuData data) async {
    final db = await database;
    final id = await db.insert(
      'rtu_data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('💾 RTU inserted with rtuDataId: $id');

    final all = await db.query('rtu_data');
    print('📋 All rows in rtu_data: $all');
  }

  /// دریافت RtuData
  static Future<List<RtuData>> getRtuData(int deviceId) async {
    final db = await database;

    final res = await db.rawQuery(
      '''
    SELECT rd.*
    FROM rtu_data rd
    INNER JOIN (
      SELECT rtuId, MAX(rtuDataId) AS maxId
      FROM rtu_data
      WHERE deviceId = ?
      GROUP BY rtuId
    ) grouped ON rd.rtuId = grouped.rtuId AND rd.rtuDataId = grouped.maxId
    WHERE rd.deviceId = ?
    ORDER BY rd.rtuId;
  ''',
      [deviceId, deviceId],
    );

    print('Filtered latest unique rtu_data rows by rtuId: $res');

    return res.map((e) => RtuData.fromMap(e)).toList();
  }

  /// ذخیره StackData
  static Future<void> insertStack(StackData data) async {
    final db = await database;
    //await db.delete('stack_data');

    final id = await db.insert(
      'stack_data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('💾 RTU inserted with stackDataId: $id');

    final all = await db.query('stack_data');
    print('📋 All rows in stack_data: $all');
  }

  /// دریافت StackData
  static Future<List<StackData>> getStackData(int deviceId) async {
    final db = await database;

    final res = await db.rawQuery(
      '''
    SELECT sd.*
    FROM stack_data sd
    INNER JOIN (
      SELECT tankId, MAX(stackDataId) AS maxId
      FROM stack_data
      WHERE deviceId = ?
      GROUP BY tankId
    ) grouped ON sd.tankId = grouped.tankId AND sd.stackDataId = grouped.maxId
    WHERE sd.deviceId = ?
    ORDER BY sd.tankId;
    ''',
      [deviceId, deviceId],
    );

    print('Latest stack_data rows by stackDataId: $res');

    return res.map((e) => StackData.fromMap(e)).toList();
  }

  /// ذخیره RelayData
  static Future<void> insertRelay(RelayData data) async {
    final db = await database;
    //await db.delete('relay_data');

    final id = await db.insert(
      'relay_data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('💾 RTU inserted with relayDataId: $id');

    final all = await db.query('relay_data');
    print('📋 All rows in relay_data: $all');
  }

  /// دریافت RelayData
  static Future<List<RelayData>> getRelayData(int deviceId) async {
    final db = await database;

    final res = await db.rawQuery(
      '''
    SELECT *
    FROM relay_data
    WHERE deviceId = ?
    GROUP BY relayId
    HAVING MAX(relayDataId)
    ORDER BY relayId;
    ''',
      [deviceId],
    );

    print('Filtered latest relay_data rows by relayDataId: $res');

    return res.map((e) => RelayData.fromMap(e)).toList();
  }
}
