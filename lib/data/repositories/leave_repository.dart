import '../../core/database/database_helper.dart';
import '../models/leave_request_model.dart';

class LeaveRepository {
  final DatabaseHelper _databaseHelper;
  
  LeaveRepository({required DatabaseHelper databaseHelper}) : _databaseHelper = databaseHelper;
  
  // Get leave requests by employee ID
  Future<List<LeaveRequest>> getLeaveRequestsByEmployeeId(int employeeId) async {
    final leaveRequestMaps = await _databaseHelper.getLeaveRequestsByEmployeeId(employeeId);
    return leaveRequestMaps.map((map) => LeaveRequest.fromMap(map)).toList();
  }
  
  // Get all pending leave requests
  Future<List<LeaveRequest>> getPendingLeaveRequests() async {
    final leaveRequestMaps = await _databaseHelper.getPendingLeaveRequests();
    return leaveRequestMaps.map((map) => LeaveRequest.fromMap(map)).toList();
  }
  
  // Create a new leave request
  Future<LeaveRequest?> createLeaveRequest(LeaveRequest leaveRequest) async {
    try {
      final now = DateTime.now().toIso8601String();
      final leaveRequestWithTimestamp = leaveRequest.copyWith(
        appliedDate: now,
      );
      
      final id = await _databaseHelper.insertLeaveRequest(leaveRequestWithTimestamp.toMap());
      if (id > 0) {
        return leaveRequestWithTimestamp.copyWith(id: id);
      }
      return null;
    } catch (e) {
      print('Error creating leave request: $e');
      return null;
    }
  }
  
  // Update leave request status (approve/reject)
  Future<bool> updateLeaveRequestStatus(int leaveRequestId, String status, int approvedBy) async {
    try {
      final db = await _databaseHelper.database;
      final leaveRequestMaps = await db.query(
        DatabaseHelper.tableLeaveRequests,
        where: 'id = ?',
        whereArgs: [leaveRequestId],
      );
      
      if (leaveRequestMaps.isEmpty) {
        return false;
      }
      
      final leaveRequest = LeaveRequest.fromMap(leaveRequestMaps.first);
      
      final updatedLeaveRequest = leaveRequest.copyWith(
        status: status,
        approvedBy: approvedBy,
        approvedDate: DateTime.now().toIso8601String(),
      );
      
      final rowsAffected = await _databaseHelper.updateLeaveRequest(updatedLeaveRequest.toMap());
      return rowsAffected > 0;
    } catch (e) {
      print('Error updating leave request status: $e');
      return false;
    }
  }
  
  // Get leave requests by status
  Future<List<LeaveRequest>> getLeaveRequestsByStatus(String status) async {
    try {
      final db = await _databaseHelper.database;
      final leaveRequestMaps = await db.query(
        DatabaseHelper.tableLeaveRequests,
        where: 'status = ?',
        whereArgs: [status],
      );
      
      return leaveRequestMaps.map((map) => LeaveRequest.fromMap(map)).toList();
    } catch (e) {
      print('Error getting leave requests by status: $e');
      return [];
    }
  }
  
  // Get leave requests by date range
  Future<List<LeaveRequest>> getLeaveRequestsByDateRange(String startDate, String endDate) async {
    try {
      final db = await _databaseHelper.database;
      final leaveRequestMaps = await db.rawQuery('''
        SELECT * FROM ${DatabaseHelper.tableLeaveRequests}
        WHERE (start_date BETWEEN ? AND ?) OR (end_date BETWEEN ? AND ?)
        OR (start_date <= ? AND end_date >= ?)
      ''', [startDate, endDate, startDate, endDate, startDate, endDate]);
      
      return leaveRequestMaps.map((map) => LeaveRequest.fromMap(map)).toList();
    } catch (e) {
      print('Error getting leave requests by date range: $e');
      return [];
    }
  }
  
  // Cancel a leave request
  Future<bool> cancelLeaveRequest(int leaveRequestId) async {
    try {
      final db = await _databaseHelper.database;
      final leaveRequestMaps = await db.query(
        DatabaseHelper.tableLeaveRequests,
        where: 'id = ?',
        whereArgs: [leaveRequestId],
      );
      
      if (leaveRequestMaps.isEmpty) {
        return false;
      }
      
      final leaveRequest = LeaveRequest.fromMap(leaveRequestMaps.first);
      
      // Only pending leave requests can be cancelled
      if (leaveRequest.status != 'pending') {
        return false;
      }
      
      final updatedLeaveRequest = leaveRequest.copyWith(
        status: 'cancelled',
      );
      
      final rowsAffected = await _databaseHelper.updateLeaveRequest(updatedLeaveRequest.toMap());
      return rowsAffected > 0;
    } catch (e) {
      print('Error cancelling leave request: $e');
      return false;
    }
  }
}
