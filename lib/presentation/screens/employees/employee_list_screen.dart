import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/employee_model.dart';
import '../../providers/auth_provider.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  bool _isLoading = true;
  List<Employee> _employees = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });

    // In a real app, this would fetch from the repository
    await Future.delayed(const Duration(seconds: 1));

    // Sample data
    final sampleEmployees = [
      Employee(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phone: '123-456-7890',
        jobTitle: 'Software Developer',
        departmentId: 1,
        managerId: null,
        hireDate: '2022-01-15',
        isActive: true,
        createdAt: '2022-01-01',
        updatedAt: '2022-01-01',
      ),
      Employee(
        id: 2,
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@example.com',
        phone: '123-456-7891',
        jobTitle: 'HR Manager',
        departmentId: 2,
        managerId: null,
        hireDate: '2021-06-10',
        isActive: true,
        createdAt: '2021-06-01',
        updatedAt: '2021-06-01',
      ),
      Employee(
        id: 3,
        firstName: 'Michael',
        lastName: 'Johnson',
        email: 'michael.johnson@example.com',
        phone: '123-456-7892',
        jobTitle: 'Project Manager',
        departmentId: 1,
        managerId: 1,
        hireDate: '2022-03-20',
        isActive: true,
        createdAt: '2022-03-01',
        updatedAt: '2022-03-01',
      ),
      Employee(
        id: 4,
        firstName: 'Emily',
        lastName: 'Davis',
        email: 'emily.davis@example.com',
        phone: '123-456-7893',
        jobTitle: 'UI/UX Designer',
        departmentId: 1,
        managerId: 3,
        hireDate: '2022-05-05',
        isActive: true,
        createdAt: '2022-05-01',
        updatedAt: '2022-05-01',
      ),
      Employee(
        id: 5,
        firstName: 'Robert',
        lastName: 'Wilson',
        email: 'robert.wilson@example.com',
        phone: '123-456-7894',
        jobTitle: 'Finance Manager',
        departmentId: 3,
        managerId: null,
        hireDate: '2021-11-15',
        isActive: true,
        createdAt: '2021-11-01',
        updatedAt: '2021-11-01',
      ),
    ];

    if (mounted) {
      setState(() {
        _employees = sampleEmployees;
        _isLoading = false;
      });
    }
  }

  List<Employee> get _filteredEmployees {
    if (_searchQuery.isEmpty) {
      return _employees;
    }
    
    final query = _searchQuery.toLowerCase();
    return _employees.where((employee) {
      return employee.firstName.toLowerCase().contains(query) ||
          employee.lastName.toLowerCase().contains(query) ||
          (employee.email?.toLowerCase() ?? '').contains(query) ||
          employee.jobTitle.toLowerCase().contains(query);
    }).toList();
  }

  void _showEmployeeDetails(Employee employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    '${employee.firstName[0]}${employee.lastName[0]}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${employee.firstName} ${employee.lastName}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  employee.jobTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              _buildDetailItem(Icons.email, 'Email', employee.email ?? 'N/A'),
              _buildDetailItem(Icons.phone, 'Phone', employee.phone ?? 'N/A'),
              _buildDetailItem(Icons.business, 'Department', 'Department ${employee.departmentId}'),
              _buildDetailItem(Icons.calendar_today, 'Hire Date', employee.hireDate),
              _buildDetailItem(Icons.person_outline, 'Status', employee.isActive ? 'ACTIVE' : 'INACTIVE'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Edit employee
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      // View attendance
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.access_time),
                    label: const Text('Attendance'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;
    final isHrManager = authProvider.isHrManager;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.titleEmployees),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
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
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
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
                            Icon(
                              Icons.person_search,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No employees found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _filteredEmployees.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final employee = _filteredEmployees[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                '${employee.firstName[0]}${employee.lastName[0]}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              '${employee.firstName} ${employee.lastName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(employee.jobTitle),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showEmployeeDetails(employee),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: (isAdmin || isHrManager)
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to add employee screen
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
