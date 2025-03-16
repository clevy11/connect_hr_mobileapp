import '../../core/database/database_helper.dart';
import '../models/employee_model.dart';

class EmployeeRepository {
  final DatabaseHelper _databaseHelper;
  
  EmployeeRepository({required DatabaseHelper databaseHelper}) : _databaseHelper = databaseHelper;
  
  // Get all employees
  Future<List<Employee>> getAllEmployees() async {
    final employeeMaps = await _databaseHelper.getAllEmployees();
    return employeeMaps.map((map) => Employee.fromMap(map)).toList();
  }
  
  // Get employee by ID
  Future<Employee?> getEmployeeById(int id) async {
    final employeeMap = await _databaseHelper.getEmployeeById(id);
    if (employeeMap != null) {
      return Employee.fromMap(employeeMap);
    }
    return null;
  }
  
  // Add new employee
  Future<Employee?> addEmployee(Employee employee) async {
    try {
      final now = DateTime.now().toIso8601String();
      final employeeWithTimestamps = employee.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      
      final id = await _databaseHelper.insertEmployee(employeeWithTimestamps.toMap());
      if (id > 0) {
        return employeeWithTimestamps.copyWith(id: id);
      }
      return null;
    } catch (e) {
      print('Error adding employee: $e');
      return null;
    }
  }
  
  // Update employee
  Future<bool> updateEmployee(Employee employee) async {
    try {
      final updatedEmployee = employee.copyWith(
        updatedAt: DateTime.now().toIso8601String(),
      );
      
      final rowsAffected = await _databaseHelper.updateEmployee(updatedEmployee.toMap());
      return rowsAffected > 0;
    } catch (e) {
      print('Error updating employee: $e');
      return false;
    }
  }
  
  // Delete employee
  Future<bool> deleteEmployee(int id) async {
    try {
      final rowsAffected = await _databaseHelper.deleteEmployee(id);
      return rowsAffected > 0;
    } catch (e) {
      print('Error deleting employee: $e');
      return false;
    }
  }
  
  // Get employees by department
  Future<List<Employee>> getEmployeesByDepartment(int departmentId) async {
    try {
      final db = await _databaseHelper.database;
      final employeeMaps = await db.query(
        DatabaseHelper.tableEmployees,
        where: 'department_id = ?',
        whereArgs: [departmentId],
      );
      
      return employeeMaps.map((map) => Employee.fromMap(map)).toList();
    } catch (e) {
      print('Error getting employees by department: $e');
      return [];
    }
  }
  
  // Get employees by manager
  Future<List<Employee>> getEmployeesByManager(int managerId) async {
    try {
      final db = await _databaseHelper.database;
      final employeeMaps = await db.query(
        DatabaseHelper.tableEmployees,
        where: 'manager_id = ?',
        whereArgs: [managerId],
      );
      
      return employeeMaps.map((map) => Employee.fromMap(map)).toList();
    } catch (e) {
      print('Error getting employees by manager: $e');
      return [];
    }
  }
}
