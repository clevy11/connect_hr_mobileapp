import '../../core/database/database_helper.dart';
import '../models/attendance_model.dart';
import 'package:intl/intl.dart';

class AttendanceRepository {
  final DatabaseHelper _databaseHelper;
  
  AttendanceRepository({required DatabaseHelper databaseHelper}) : _databaseHelper = databaseHelper;
  
  // Get attendance records by employee ID
  Future<List<Attendance>> getAttendanceByEmployeeId(int employeeId) async {
    final db = await _databaseHelper.database;
    final attendanceMaps = await db.query(
      DatabaseHelper.tableAttendance,
      where: 'employee_id = ?',
      whereArgs: [employeeId],
    );
    return attendanceMaps.map((map) => Attendance.fromMap(map)).toList();
  }
  
  // Get attendance records by date
  Future<List<Attendance>> getAttendanceByDate(String date) async {
    final db = await _databaseHelper.database;
    final attendanceMaps = await db.query(
      DatabaseHelper.tableAttendance,
      where: 'date = ?',
      whereArgs: [date],
    );
    return attendanceMaps.map((map) => Attendance.fromMap(map)).toList();
  }
  
  // Format current date in database format
  String _getCurrentFormattedDate() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }
  
  // Format current time in database format
  String _getCurrentFormattedTime() {
    final now = DateTime.now();
    return DateFormat('HH:mm:ss').format(now);
  }
  
  // Clock in
  Future<Attendance?> clockIn(int userId, {String? notes}) async {
    try {
      final db = await _databaseHelper.database;
      final today = _getCurrentFormattedDate();
      final currentTime = _getCurrentFormattedTime();
      
      // Check if there's already an attendance record for today
      final List<Map<String, dynamic>> result = await db.query(
        DatabaseHelper.tableAttendance,
        where: 'employee_id = ? AND date = ?',
        whereArgs: [userId, today],
      );
      
      if (result.isNotEmpty) {
        // If already clocked in, return the existing record
        final attendance = Attendance.fromMap(result.first);
        
        // If already clocked in, just return the record
        if (attendance.clockIn.isNotEmpty) {
          return attendance;
        }
        
        // If record exists but no clock in time (rare case), update it
        final Map<String, dynamic> updateValues = {
          'clock_in': currentTime,
          'notes': notes,
        };
        
        final rowsAffected = await db.update(
          DatabaseHelper.tableAttendance,
          updateValues,
          where: 'id = ?',
          whereArgs: [attendance.id],
        );
        
        if (rowsAffected > 0) {
          return attendance.copyWith(
            clockIn: currentTime,
            notes: notes,
          );
        }
      } else {
        // Create a new attendance record
        final Map<String, dynamic> insertValues = {
          'employee_id': userId,
          'date': today,
          'clock_in': currentTime,
          'clock_out': '',
          'status': 'present',
          'notes': notes,
        };
        
        final id = await db.insert(
          DatabaseHelper.tableAttendance,
          insertValues,
        );
        
        if (id > 0) {
          return Attendance(
            id: id,
            employeeId: userId,
            date: today,
            clockIn: currentTime,
            clockOut: '',
            status: 'present',
            notes: notes,
          );
        }
      }
    } catch (e) {
      print('Error clocking in: $e');
    }
    
    return null;
  }
  
  // Clock out
  Future<Attendance?> clockOut(int userId, {String? notes}) async {
    try {
      final db = await _databaseHelper.database;
      final today = _getCurrentFormattedDate();
      final currentTime = _getCurrentFormattedTime();
      
      // Check if there's an attendance record for today
      final List<Map<String, dynamic>> result = await db.query(
        DatabaseHelper.tableAttendance,
        where: 'employee_id = ? AND date = ?',
        whereArgs: [userId, today],
      );
      
      if (result.isEmpty) {
        // No attendance record for today
        return null;
      }
      
      // Get the existing attendance record
      final attendance = Attendance.fromMap(result.first);
      
      // If already clocked out, just return the record
      if (attendance.clockOut.isNotEmpty) {
        return attendance;
      }
      
      // Update the record with clock out time
      final Map<String, dynamic> updateValues = {
        'clock_out': currentTime,
      };
      
      if (notes != null) {
        updateValues['notes'] = notes;
      }
      
      final rowsAffected = await db.update(
        DatabaseHelper.tableAttendance,
        updateValues,
        where: 'id = ?',
        whereArgs: [attendance.id],
      );
      
      if (rowsAffected > 0) {
        return attendance.copyWith(
          clockOut: currentTime,
          notes: notes ?? attendance.notes,
        );
      }
    } catch (e) {
      print('Error clocking out: $e');
    }
    
    return null;
  }
  
  // Get today's attendance for an employee
  Future<Attendance?> getTodayAttendance(int employeeId) async {
    try {
      final date = _getCurrentFormattedDate();
      
      final db = await _databaseHelper.database;
      final attendanceMaps = await db.query(
        DatabaseHelper.tableAttendance,
        where: 'employee_id = ? AND date = ?',
        whereArgs: [employeeId, date],
      );
      
      if (attendanceMaps.isNotEmpty) {
        return Attendance.fromMap(attendanceMaps.first);
      }
      return null;
    } catch (e) {
      print('Error getting today\'s attendance: $e');
      return null;
    }
  }
  
  // Get attendance statistics for an employee
  Future<Map<String, dynamic>> getAttendanceStats(int employeeId, {String? startDate, String? endDate}) async {
    try {
      final db = await _databaseHelper.database;
      
      String whereClause = 'employee_id = ?';
      List<dynamic> whereArgs = [employeeId];
      
      if (startDate != null && endDate != null) {
        whereClause += ' AND date BETWEEN ? AND ?';
        whereArgs.addAll([startDate, endDate]);
      } else if (startDate != null) {
        whereClause += ' AND date >= ?';
        whereArgs.add(startDate);
      } else if (endDate != null) {
        whereClause += ' AND date <= ?';
        whereArgs.add(endDate);
      }
      
      final attendanceMaps = await db.query(
        DatabaseHelper.tableAttendance,
        where: whereClause,
        whereArgs: whereArgs,
      );
      
      final attendances = attendanceMaps.map((map) => Attendance.fromMap(map)).toList();
      
      // Calculate statistics
      int present = 0;
      int absent = 0;
      int late = 0;
      int halfDay = 0;
      
      for (var attendance in attendances) {
        switch (attendance.status.toLowerCase()) {
          case 'present':
            present++;
            break;
          case 'absent':
            absent++;
            break;
          case 'late':
            late++;
            break;
          case 'half_day':
            halfDay++;
            break;
        }
      }
      
      return {
        'total': attendances.length,
        'present': present,
        'absent': absent,
        'late': late,
        'half_day': halfDay,
        'attendance_rate': attendances.isEmpty ? 0 : (present / attendances.length * 100).toInt(),
      };
    } catch (e) {
      print('Error getting attendance statistics: $e');
      return {
        'total': 0,
        'present': 0,
        'absent': 0,
        'late': 0,
        'half_day': 0,
        'attendance_rate': 0,
      };
    }
  }
  
  // Get attendance by date range
  Future<List<Attendance>> getAttendanceByDateRange(
    int employeeId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final db = await _databaseHelper.database;
      final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);
      
      final attendanceMaps = await db.query(
        DatabaseHelper.tableAttendance,
        where: 'employee_id = ? AND date BETWEEN ? AND ?',
        whereArgs: [employeeId, startDateStr, endDateStr],
        orderBy: 'date DESC',
      );
      
      return attendanceMaps.map((map) => Attendance.fromMap(map)).toList();
    } catch (e) {
      print('Error getting attendance by date range: $e');
      return [];
    }
  }
}
