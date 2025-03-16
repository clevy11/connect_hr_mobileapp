import '../../core/database/database_helper.dart';
import '../models/department_model.dart';
import 'package:sqflite/sqflite.dart';

class DepartmentRepository {
  final DatabaseHelper _databaseHelper;
  
  DepartmentRepository({required DatabaseHelper databaseHelper}) : _databaseHelper = databaseHelper;
  
  // Get all departments
  Future<List<Department>> getAllDepartments() async {
    final departmentMaps = await _databaseHelper.getAllDepartments();
    return departmentMaps.map((map) => Department.fromMap(map)).toList();
  }
  
  // Get department by ID
  Future<Department?> getDepartmentById(int id) async {
    try {
      final db = await _databaseHelper.database;
      final departmentMaps = await db.query(
        DatabaseHelper.tableDepartments,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (departmentMaps.isNotEmpty) {
        return Department.fromMap(departmentMaps.first);
      }
      return null;
    } catch (e) {
      print('Error getting department by ID: $e');
      return null;
    }
  }
  
  // Create a new department
  Future<Department?> createDepartment(Department department) async {
    try {
      final now = DateTime.now().toIso8601String();
      final departmentWithTimestamp = department.copyWith(
        createdAt: now,
      );
      
      final id = await _databaseHelper.insertDepartment(departmentWithTimestamp.toMap());
      if (id > 0) {
        return departmentWithTimestamp.copyWith(id: id);
      }
      return null;
    } catch (e) {
      print('Error creating department: $e');
      return null;
    }
  }
  
  // Update department
  Future<bool> updateDepartment(Department department) async {
    try {
      final db = await _databaseHelper.database;
      final rowsAffected = await db.update(
        DatabaseHelper.tableDepartments,
        department.toMap(),
        where: 'id = ?',
        whereArgs: [department.id],
      );
      
      return rowsAffected > 0;
    } catch (e) {
      print('Error updating department: $e');
      return false;
    }
  }
  
  // Delete department
  Future<bool> deleteDepartment(int id) async {
    try {
      // First check if there are employees in this department
      final db = await _databaseHelper.database;
      final employeeCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseHelper.tableEmployees} WHERE department_id = ?',
        [id],
      ));
      
      if (employeeCount != null && employeeCount > 0) {
        // Cannot delete department with employees
        return false;
      }
      
      final rowsAffected = await db.delete(
        DatabaseHelper.tableDepartments,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      return rowsAffected > 0;
    } catch (e) {
      print('Error deleting department: $e');
      return false;
    }
  }
  
  // Get department statistics
  Future<Map<String, dynamic>> getDepartmentStatistics(int departmentId) async {
    try {
      final db = await _databaseHelper.database;
      
      // Get employee count
      final employeeCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseHelper.tableEmployees} WHERE department_id = ?',
        [departmentId],
      )) ?? 0;
      
      // Get average salary
      final avgSalaryResult = await db.rawQuery(
        'SELECT AVG(salary) as avg_salary FROM ${DatabaseHelper.tableEmployees} WHERE department_id = ?',
        [departmentId],
      );
      final avgSalary = avgSalaryResult.isNotEmpty ? avgSalaryResult.first['avg_salary'] as double? ?? 0.0 : 0.0;
      
      return {
        'employee_count': employeeCount,
        'average_salary': avgSalary,
      };
    } catch (e) {
      print('Error getting department statistics: $e');
      return {
        'employee_count': 0,
        'average_salary': 0.0,
      };
    }
  }
}
