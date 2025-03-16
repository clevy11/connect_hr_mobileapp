import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/database/database_helper.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/repositories/employee_repository.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/employee/employee_list_item.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  late EmployeeRepository _employeeRepository;
  bool _isLoading = true;
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final databaseHelper = DatabaseHelper();
    _employeeRepository = EmployeeRepository(databaseHelper: databaseHelper);
    
    await _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final employees = await _employeeRepository.getAllEmployees();
      
      setState(() {
        _employees = employees;
        _filteredEmployees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading employees: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _filterEmployees(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredEmployees = _employees;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        return employee.firstName.toLowerCase().contains(lowercaseQuery) ||
               employee.lastName.toLowerCase().contains(lowercaseQuery) ||
               employee.jobTitle.toLowerCase().contains(lowercaseQuery) ||
               (employee.email != null && employee.email!.toLowerCase().contains(lowercaseQuery));
      }).toList();
    });
  }

  Future<void> _addEmployee() async {
    final result = await Navigator.pushNamed(
      context,
      '/admin/add_edit_employee',
      arguments: {'employee': null},
    );

    if (result == true) {
      await _loadEmployees();
    }
  }

  Future<void> _editEmployee(Employee employee) async {
    final result = await Navigator.pushNamed(
      context,
      '/admin/add_edit_employee',
      arguments: {'employee': employee},
    );

    if (result == true) {
      await _loadEmployees();
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _employeeRepository.deleteEmployee(employee.id!);
        
        if (success) {
          await _loadEmployees();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Employee deleted successfully'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete employee'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting employee: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;
    final isHrManager = authProvider.isHrManager;
    
    // Only admins and HR managers can access this screen
    if (!isAdmin && !isHrManager) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Employee Management'),
        ),
        body: const Center(
          child: Text(
            'You do not have permission to access this page',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterEmployees('');
                        },
                      )
                    : null,
              ),
              onChanged: _filterEmployees,
            ),
          ),
          
          // Employee list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEmployees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No employees match your search'
                                  : 'No employees found',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_searchController.text.isNotEmpty)
                              ElevatedButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _filterEmployees('');
                                },
                                child: const Text('Clear Search'),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = _filteredEmployees[index];
                          return EmployeeListItem(
                            employee: employee,
                            onEdit: () => _editEmployee(employee),
                            onDelete: () => _deleteEmployee(employee),
                            onTap: () => _editEmployee(employee),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEmployee,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
