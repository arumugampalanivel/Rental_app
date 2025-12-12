import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:rent_manager/utils/date_utils.dart';
import '../models/room_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, "rent_manager.db");
    print(await getDatabasesPath());
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // Tenant Table
    await db.execute('''
      CREATE TABLE tenants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        photo TEXT,
        mobile TEXT,
        dob TEXT,
        gender TEXT,
        address TEXT,
        occupation TEXT,
        emergency TEXT
      )
    ''');

    // Company Table
    await db.execute('''
      CREATE TABLE company (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_name TEXT,
        location TEXT,
        designation TEXT,
        date_of_joining  TEXT,
        id_card_image  TEXT
      )
    ''');

    // TENANT ROOM ASSIGNMENT TABLE
    await db.execute('''
    CREATE TABLE rooms (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tenant_id INTEGER,
      room_no TEXT,
      advance REAL,
      rent REAL,
      rent_date TEXT,
      notes TEXT
    )
  ''');

    await db.execute('''
  CREATE TABLE room (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_id INTEGER,
    room_no TEXT,
    floor TEXT,
    location TEXT,
    advance REAL,
    rent TEXT,
    max_occupants INTEGER,
    notes TEXT,
    status TEXT
  )
''');

    // Rent History
    await db.execute('''
      CREATE TABLE rent_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tenant_id INTEGER,
        month TEXT,
        amount TEXT,
        paid_date TEXT,
        status TEXT,
        note TEXT,
        FOREIGN KEY (tenant_id) REFERENCES tenants(id)
      )
    ''');
  }

  // ================= INSERT FUNCTIONS =================

  // tenant count

  Future<int> countTenantsInRoom(int roomId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM tenants WHERE room_id = ?',
      [roomId],
    );
    return result.first['count'] as int;
  }

  Future<List<RoomModel>> getAllRooms() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'rooms',
      orderBy: 'room_no ASC',
    );

    return result.map((row) => RoomModel.fromMap(row)).toList();
  }

  Future<int> deleteRoom(int id) async {
    final db = await database;
    return await db.delete('rooms', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertTenant(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert("tenants", data);
  }

  Future<int> insertCompany(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert("company", data);
  }

  Future<int> insertRoom(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert("room", data);
  }

  Future<int> insertRent(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert("rent_history", data);
  }

  // ================= GET FUNCTIONS =================

  Future<List<Map<String, dynamic>>> getAllTenants() async {
    final db = await database;
    return db.query("tenants", orderBy: "id DESC");
  }

  Future<List<Map<String, dynamic>>> getTenantDetails(int id) async {
    final db = await database;
    return db.query("tenants", where: "id = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getRentHistory(int tenantId) async {
    final db = await database;
    return await db.query(
      'rent_history',
      where: 'tenant_id = ?',
      whereArgs: [tenantId],
      orderBy: 'id DESC',
    );
  }

  Future<int> removeTenantFromRoom(int tenantId) async {
    final db = await database;
    return await db.delete(
      'room',
      where: 'tenant_id = ?',
      whereArgs: [tenantId],
    );
  }

  /// Returns the last paid month string (e.g. "January 2025") or null if none.
  Future<String?> getLastPaidMonth(int tenantId) async {
    final db = await database; // make sure this awaits your initialized DB

    // Defensive: make sure table exists (helps debugging)
    // If this throws "no such table", see the troubleshooting section below.
    final List<Map<String, Object?>> rows = await db.query(
      'rent_history',
      where: 'tenant_id = ? AND status = ?',
      whereArgs: [tenantId, 'Paid'],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final value = rows.first['month'];
    if (value == null) return null;
    return value.toString();
  }

  Future<List<String>> getPendingMonths(int tenantId) async {
    final lastPaid = await getLastPaidMonth(tenantId);

    if (lastPaid == null) {
      return []; // no paid history → assume no pending OR decide first month logic later
    }

    // Generate months between last paid and today
    return RentDateUtils.generateMonthList(lastPaid);
  }

  //Get total tenant count
  Future<int> getTotalTenantCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM tenants');
    return result.first['count'] as int;
  }

  // Get list of tenants with pending rent

  Future<int> getPendingTenantCount() async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT DISTINCT tenant_id 
    FROM rent_history 
    WHERE status = 'Pending'
  ''');
    return result.length;
  }

  // Get total rent collected this month

  Future<double> getMonthlyCollectedAmount() async {
    final db = await database;

    final now = DateTime.now();
    final monthStr = "${_monthName(now.month)} ${now.year}";

    final result = await db.rawQuery(
      '''
    SELECT SUM(amount) AS total 
    FROM rent_history 
    WHERE month = ?
    AND status = 'Paid'
  ''',
      [monthStr],
    );

    final value = result.first['total'];
    if (value == null) return 0.0;

    return double.tryParse(value.toString()) ?? 0.0;
  }

  String _monthName(int m) {
    const names = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return names[m];
  }

  // getTenantById()

  Future<Map<String, dynamic>?> getTenantById(int id) async {
    final db = await database;

    final result = await db.query(
      'tenants',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // room status
  String getRoomStatus(int current, int max) {
    return current >= max ? "Occupied" : "Vacant";
  }

  //deleteTenant()

  Future<int> deleteTenant(int id) async {
    final db = await database;
    return await db.delete('tenants', where: 'id = ?', whereArgs: [id]);
  }

  //===== update functions ======
  Future<int> updateTenant(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('tenants', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateCompany(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('company', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateRoom(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('room', data, where: 'id = ?', whereArgs: [id]);
  }
}
