import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/models/leave_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/dashboard/dashboard_card.dart';
import '../../widgets/dashboard/recent_activity_item.dart';
import '../attendance/attendance_screen.dart';
import '../admin/employee_management_screen.dart';
import '../leave/leave_request_list_screen.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  int _employeeCount = 0;
  int _attendanceToday = 0;
  int _pendingLeaveRequests = 0;
  int _departmentCount = 0;
  
  // Sample data for charts
  final List<FlSpot> _attendanceData = [
    FlSpot(0, 5),
    FlSpot(1, 8),
    FlSpot(2, 10),
    FlSpot(3, 7),
    FlSpot(4, 12),
    FlSpot(5, 13),
    FlSpot(6, 9),
  ];
  
  final List<PieChartSectionData> _departmentData = [
    PieChartSectionData(
      color: AppTheme.primaryColor,
      value: 35,
      title: 'IT',
      radius: 50,
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
    ),
    PieChartSectionData(
      color: AppTheme.secondaryColor,
      value: 25,
      title: 'HR',
      radius: 50,
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
    ),
    PieChartSectionData(
      color: AppTheme.accentColor,
      value: 20,
      title: 'Finance',
      radius: 50,
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
    ),
    PieChartSectionData(
      color: AppTheme.successColor,
      value: 15,
      title: 'Sales',
      radius: 50,
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
    ),
    PieChartSectionData(
      color: AppTheme.infoColor,
      value: 5,
      title: 'Other',
      radius: 50,
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
    ),
  ];
  
  // Sample recent activities
  final List<Map<String, dynamic>> _recentActivities = [
    {
      'type': 'attendance',
      'title': 'John Doe clocked in',
      'time': DateTime.now().subtract(const Duration(minutes: 15)),
    },
    {
      'type': 'leave',
      'title': 'Sarah Smith requested leave',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'type': 'employee',
      'title': 'New employee Michael Johnson added',
      'time': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'type': 'attendance',
      'title': 'Emily Davis clocked out',
      'time': DateTime.now().subtract(const Duration(hours: 8)),
    },
    {
      'type': 'leave',
      'title': 'Robert Wilson\'s leave approved',
      'time': DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    // In a real app, this would fetch data from repositories
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _employeeCount = 42;
        _attendanceToday = 38;
        _pendingLeaveRequests = 5;
        _departmentCount = 6;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _isLoading = true;
    });
    
    await _loadDashboardData();
  }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isAdmin = authProvider.isAdmin;
    final isHrManager = authProvider.isHrManager;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.titleDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboard,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text(AppConstants.confirmLogout),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(AppConstants.buttonCancel),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _logout();
                      },
                      child: const Text(AppConstants.buttonLogout),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                user?.username ?? 'User',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                user?.role.replaceAll('_', ' ').toUpperCase() ?? '',
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (user?.username.isNotEmpty ?? false) 
                      ? user!.username[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text(AppConstants.navDashboard),
              selected: true,
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            if (isAdmin || isHrManager)
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text(AppConstants.navEmployees),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EmployeeManagementScreen(),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text(AppConstants.navAttendance),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AttendanceScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_note),
              title: const Text(AppConstants.navLeave),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LeaveRequestListScreen(),
                  ),
                );
              },
            ),
            if (isAdmin || isHrManager)
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text(AppConstants.navReports),
                onTap: () {
                  Navigator.of(context).pop();
                  // Navigate to reports screen
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text(AppConstants.navSettings),
              onTap: () {
                Navigator.of(context).pop();
                // Navigate to settings screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(AppConstants.buttonLogout),
              onTap: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshDashboard,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message
                    Text(
                      'Welcome, ${user?.username ?? 'User'}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Dashboard cards
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        DashboardCard(
                          title: 'Employees',
                          value: _employeeCount.toString(),
                          icon: Icons.people,
                          color: AppTheme.primaryColor,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EmployeeManagementScreen(),
                              ),
                            );
                          },
                        ),
                        DashboardCard(
                          title: 'Attendance Today',
                          value: '$_attendanceToday/$_employeeCount',
                          icon: Icons.access_time,
                          color: AppTheme.secondaryColor,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AttendanceScreen(),
                              ),
                            );
                          },
                        ),
                        DashboardCard(
                          title: 'Pending Leaves',
                          value: _pendingLeaveRequests.toString(),
                          icon: Icons.event_note,
                          color: AppTheme.accentColor,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LeaveRequestListScreen(),
                              ),
                            );
                          },
                        ),
                        DashboardCard(
                          title: 'Departments',
                          value: _departmentCount.toString(),
                          icon: Icons.business,
                          color: AppTheme.infoColor,
                          onTap: () {
                            // Navigate to departments screen
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Admin and HR Manager Cards
                    if (isAdmin || isHrManager) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Administration',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DashboardCard(
                              title: 'Employee Management',
                              value: '$_employeeCount',
                              icon: Icons.people,
                              color: AppTheme.primaryColor,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const EmployeeManagementScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DashboardCard(
                              title: 'Departments',
                              value: '$_departmentCount',
                              icon: Icons.business,
                              color: AppTheme.secondaryColor,
                              onTap: () {
                                // Navigate to departments screen
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    
                    // Charts section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TabBar(
                              controller: _tabController,
                              labelColor: AppTheme.primaryColor,
                              unselectedLabelColor: AppTheme.textSecondaryColor,
                              indicatorColor: AppTheme.primaryColor,
                              tabs: const [
                                Tab(text: 'Attendance'),
                                Tab(text: 'Departments'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 250,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  // Attendance Chart
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Weekly Attendance',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: LineChart(
                                          LineChartData(
                                            gridData: FlGridData(show: false),
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (value, meta) {
                                                    return Text(
                                                      value.toInt().toString(),
                                                      style: const TextStyle(
                                                        color: AppTheme.textSecondaryColor,
                                                        fontSize: 12,
                                                      ),
                                                    );
                                                  },
                                                  reservedSize: 30,
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (value, meta) {
                                                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                                    if (value.toInt() >= 0 && value.toInt() < days.length) {
                                                      return Text(
                                                        days[value.toInt()],
                                                        style: const TextStyle(
                                                          color: AppTheme.textSecondaryColor,
                                                          fontSize: 12,
                                                        ),
                                                      );
                                                    }
                                                    return const Text('');
                                                  },
                                                  reservedSize: 30,
                                                ),
                                              ),
                                              rightTitles: AxisTitles(
                                                sideTitles: SideTitles(showTitles: false),
                                              ),
                                              topTitles: AxisTitles(
                                                sideTitles: SideTitles(showTitles: false),
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: true,
                                              border: Border.all(
                                                color: AppTheme.textLightColor,
                                                width: 1,
                                              ),
                                            ),
                                            minX: 0,
                                            maxX: 6,
                                            minY: 0,
                                            maxY: 15,
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: _attendanceData,
                                                isCurved: true,
                                                color: AppTheme.primaryColor,
                                                barWidth: 3,
                                                isStrokeCapRound: true,
                                                dotData: FlDotData(show: true),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  color: AppTheme.primaryColor.withOpacity(0.2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Department Distribution Chart
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Department Distribution',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: PieChart(
                                          PieChartData(
                                            sections: _departmentData,
                                            centerSpaceRadius: 40,
                                            sectionsSpace: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Recent Activity
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recentActivities.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final activity = _recentActivities[index];
                          return RecentActivityItem(
                            type: activity['type'],
                            title: activity['title'],
                            time: activity['time'],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show quick actions menu
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickActionButton(
                        context,
                        icon: Icons.access_time,
                        label: 'Clock In/Out',
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AttendanceScreen(),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.event_note,
                        label: 'Request Leave',
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LeaveRequestListScreen(),
                            ),
                          );
                        },
                      ),
                      if (isAdmin || isHrManager)
                        _buildQuickActionButton(
                          context,
                          icon: Icons.person_add,
                          label: 'Add Employee',
                          onTap: () {
                            Navigator.of(context).pop();
                            // Navigate to add employee screen
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
