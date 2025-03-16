import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Database version and name
  static const _databaseName = "hr_management.db";
  static const _databaseVersion = 1;

  // Table names
  static const String tableUsers = 'users';
  static const String tableEmployees = 'employees';
  static const String tableAttendance = 'attendance';
  static const String tableLeaveRequests = 'leave_requests';
  static const String tableDepartments = 'departments';

  // Factory constructor
  factory DatabaseHelper() => _instance;

  // Internal constructor
  DatabaseHelper._internal();

  // Database getter
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Users table (for authentication)
    await db.execute('''
      CREATE TABLE $tableUsers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        employee_id INTEGER NULL,
        created_at TEXT NOT NULL,
        last_login TEXT NULL
      )
    ''');

    // Departments table
    await db.execute('''
      CREATE TABLE $tableDepartments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Employees table
    await db.execute('''
      CREATE TABLE $tableEmployees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT UNIQUE,
        phone TEXT NULL,
        address TEXT NULL,
        date_of_birth TEXT NULL,
        gender TEXT NULL,
        job_title TEXT NOT NULL,
        department_id INTEGER NULL,
        manager_id INTEGER NULL,
        hire_date TEXT NOT NULL,
        salary REAL NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        profile_image TEXT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (department_id) REFERENCES $tableDepartments (id),
        FOREIGN KEY (manager_id) REFERENCES $tableEmployees (id)
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE $tableAttendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        clock_in TEXT NOT NULL,
        clock_out TEXT NULL,
        status TEXT NOT NULL,
        notes TEXT NULL,
        FOREIGN KEY (employee_id) REFERENCES $tableEmployees (id)
      )
    ''');

    // Leave requests table
    await db.execute('''
      CREATE TABLE $tableLeaveRequests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id INTEGER NOT NULL,
        leave_type TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        reason TEXT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        approved_by INTEGER NULL,
        approved_at TEXT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (employee_id) REFERENCES $tableEmployees (id),
        FOREIGN KEY (approved_by) REFERENCES $tableEmployees (id)
      )
    ''');

    // Insert default admin user
    await db.insert(tableUsers, {
      'username': 'admin',
      'password': 'admin123', // In production, this should be hashed
      'role': 'admin',
      'employee_id': null,
      'created_at': DateTime.now().toIso8601String(),
      'last_login': null
    });

    // Insert default department
    int hrDeptId = await db.insert(tableDepartments, {
      'name': 'Human Resources',
      'description': 'HR Department',
      'created_at': DateTime.now().toIso8601String()
    });

    // Insert default HR manager
    await db.insert(tableEmployees, {
      'first_name': 'HR',
      'last_name': 'Manager',
      'email': 'hr@example.com',
      'job_title': 'HR Manager',
      'department_id': hrDeptId,
      'manager_id': null,
      'hire_date': DateTime.now().toIso8601String(),
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String()
    });
  }

  // Database upgrade function
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Handle database migrations here
    }
  }

  // CRUD Operations for Users
  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tableUsers, row);
  }

  Future<int> updateUser(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update(
      tableUsers,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // CRUD Operations for Employees
  Future<int> insertEmployee(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tableEmployees, row);
  }

  Future<int> updateEmployee(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update(
      tableEmployees,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteEmployee(int id) async {
    Database db = await database;
    return await db.delete(
      tableEmployees,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    Database db = await database;
    return await db.query(tableEmployees);
  }

  Future<Map<String, dynamic>?> getEmployeeById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableEmployees,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // CRUD Operations for Attendance
  Future<int> insertAttendance(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tableAttendance, row);
  }

  Future<int> updateAttendance(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update(
      tableAttendance,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAttendanceByEmployeeId(int employeeId) async {
    Database db = await database;
    return await db.query(
      tableAttendance,
      where: 'employee_id = ?',
      whereArgs: [employeeId],
    );
  }

  Future<List<Map<String, dynamic>>> getAttendanceByDate(String date) async {
    Database db = await database;
    return await db.query(
      tableAttendance,
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  // CRUD Operations for Leave Requests
  Future<int> insertLeaveRequest(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tableLeaveRequests, row);
  }

  Future<int> updateLeaveRequest(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update(
      tableLeaveRequests,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getLeaveRequestsByEmployeeId(int employeeId) async {
    Database db = await database;
    return await db.query(
      tableLeaveRequests,
      where: 'employee_id = ?',
      whereArgs: [employeeId],
    );
  }

  Future<List<Map<String, dynamic>>> getPendingLeaveRequests() async {
    Database db = await database;
    return await db.query(
      tableLeaveRequests,
      where: 'status = ?',
      whereArgs: ['pending'],
    );
  }

  // CRUD Operations for Departments
  Future<int> insertDepartment(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tableDepartments, row);
  }

  Future<List<Map<String, dynamic>>> getAllDepartments() async {
    Database db = await database;
    return await db.query(tableDepartments);
  }

  // Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
