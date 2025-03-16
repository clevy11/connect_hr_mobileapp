import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../../providers/auth_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Attendance> _attendanceRecords = [];
  DateTime _selectedDate = DateTime.now();
  bool _isClockedIn = false;
  bool _isClockedOut = false;
  DateTime _clockInTime = DateTime.now();
  Attendance? _todayAttendance;
  late AttendanceRepository _attendanceRepository;
  int? _userId;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDate = DateTime.now();
    _initializeData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Initialize the attendance repository
      final databaseHelper = DatabaseHelper();
      _attendanceRepository = AttendanceRepository(databaseHelper: databaseHelper);
      
      // Get the user ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      
      if (userId != null) {
        _userId = userId;
        await _loadAttendanceData();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadAttendanceData() async {
    try {
      if (_userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Get today's date
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Get today's attendance record
      final todayRecord = await _attendanceRepository.getTodayAttendance(_userId!);
      
      setState(() {
        _todayAttendance = todayRecord;
        
        if (_todayAttendance != null) {
          _isClockedIn = _todayAttendance!.clockIn.isNotEmpty;
          _isClockedOut = _todayAttendance!.clockOut.isNotEmpty;
          
          if (_isClockedIn) {
            try {
              _clockInTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(
                '${_todayAttendance!.date} ${_todayAttendance!.clockIn}'
              );
            } catch (e) {
              // If parsing fails, use current time as fallback
              _clockInTime = DateTime.now();
              print('Error parsing clock in time: $e');
            }
          }
        } else {
          _isClockedIn = false;
          _isClockedOut = false;
        }
        
        // Get attendance records for the selected month
        final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
        final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
        
        _attendanceRepository
            .getAttendanceByDateRange(_userId!, startDate: startDate, endDate: endDate)
            .then((records) {
          setState(() {
            _attendanceRecords = records;
            _isLoading = false;
          });
        });
      });
    } catch (e) {
      print('Error loading attendance data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _clockIn() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to clock in'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Call the repository to clock in
      final attendance = await _attendanceRepository.clockIn(_userId!);
      
      if (attendance != null) {
        setState(() {
          _isClockedIn = true;
          _clockInTime = DateTime.now();
          _todayAttendance = attendance;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully clocked in at ${DateFormat('hh:mm a').format(_clockInTime)}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        // Reload attendance data to refresh the UI
        _loadAttendanceData();
      } else {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to clock in. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      print('Error clocking in: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clocking in: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  Future<void> _clockOut() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to clock out'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Call the repository to clock out
      final attendance = await _attendanceRepository.clockOut(_userId!);
      
      if (attendance != null) {
        final clockOutTime = DateTime.now();
        
        setState(() {
          _isClockedOut = true;
          _todayAttendance = attendance;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully clocked out at ${DateFormat('hh:mm a').format(clockOutTime)}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to clock out. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clocking out: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.titleAttendance),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTodayTab(authProvider),
                
                // History Tab
                _buildHistoryTab(),
              ],
            ),
    );
  }
  
  Widget _buildTodayTab(AuthProvider authProvider) {
    // If user is not logged in or cannot use attendance, show a message
    if (!authProvider.canUseAttendance) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                size: 48,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Attendance Tracking',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'You need to be logged in to use the attendance system.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                icon: const Icon(Icons.login),
                label: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's date
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Clock In/Out Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Clock In Status
                  Row(
                    children: [
                      const Icon(
                        Icons.login,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Clock In:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isClockedIn
                            ? DateFormat('hh:mm a').format(_clockInTime)
                            : 'Not clocked in',
                        style: TextStyle(
                          fontSize: 16,
                          color: _isClockedIn
                              ? AppTheme.successColor
                              : AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Clock Out Status
                  Row(
                    children: [
                      const Icon(
                        Icons.logout,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Clock Out:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isClockedOut && _todayAttendance != null
                            ? DateFormat('hh:mm a').format(
                                _todayAttendance!.clockOut != null && _todayAttendance!.clockOut!.isNotEmpty
                                  ? DateFormat('yyyy-MM-dd HH:mm:ss').parse(
                                      '${_todayAttendance!.date} ${_todayAttendance!.clockOut}'
                                    )
                                  : DateTime.now()
                              )
                            : 'Not clocked out',
                        style: TextStyle(
                          fontSize: 16,
                          color: _isClockedOut
                              ? AppTheme.successColor
                              : AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Clock In/Out Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isClockedIn ? null : _clockIn,
                        icon: const Icon(Icons.login),
                        label: const Text('Clock In'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: (!_isClockedIn || _isClockedOut) ? null : _clockOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Clock Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Working Hours Summary
          if (_isClockedIn)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Working Hours',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isClockedOut
                              ? _calculateWorkingHours()
                              : 'In progress...',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  String _calculateWorkingHours() {
    if (!_isClockedIn || !_isClockedOut || _todayAttendance == null) {
      return 'N/A';
    }
    
    try {
      final clockIn = DateFormat('yyyy-MM-dd HH:mm:ss').parse(
        '${_todayAttendance!.date} ${_todayAttendance!.clockIn}'
      );
      
      final clockOut = DateFormat('yyyy-MM-dd HH:mm:ss').parse(
        '${_todayAttendance!.date} ${_todayAttendance!.clockOut}'
      );
      
      final difference = clockOut.difference(clockIn);
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      
      return '$hours hr ${minutes.toString().padLeft(2, '0')} min';
    } catch (e) {
      debugPrint('Error calculating working hours: $e');
      return 'N/A';
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      
      // Reload attendance data for the selected date
      _loadAttendanceData();
    }
  }
  
  Widget _buildHistoryTab() {
    return Column(
      children: [
        // Date selector
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(DateFormat('MMM yyyy').format(_selectedDate)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Attendance records
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _attendanceRecords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.event_busy,
                            size: 64,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No attendance records found',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try selecting a different date',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _attendanceRecords.length,
                      itemBuilder: (context, index) {
                        final record = _attendanceRecords[index];
                        final recordDate = DateFormat('yyyy-MM-dd').parse(record.date);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: record.status == AppConstants.statusPresent
                                    ? AppTheme.successColor.withOpacity(0.1)
                                    : record.status == AppConstants.statusAbsent
                                        ? AppTheme.errorColor.withOpacity(0.1)
                                        : AppTheme.warningColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  record.status == AppConstants.statusPresent
                                      ? Icons.check_circle_outline
                                      : record.status == AppConstants.statusAbsent
                                          ? Icons.cancel_outlined
                                          : Icons.access_time,
                                  color: record.status == AppConstants.statusPresent
                                      ? AppTheme.successColor
                                      : record.status == AppConstants.statusAbsent
                                          ? AppTheme.errorColor
                                          : AppTheme.warningColor,
                                  size: 28,
                                ),
                              ),
                            ),
                            title: Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(recordDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.login, size: 14, color: AppTheme.textSecondaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      record.clockIn.isNotEmpty
                                          ? DateFormat('hh:mm a').format(
                                              DateFormat('HH:mm:ss').parse(record.clockIn)
                                            )
                                          : 'N/A',
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.logout, size: 14, color: AppTheme.textSecondaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      record.clockOut.isNotEmpty
                                          ? DateFormat('hh:mm a').format(
                                              DateFormat('HH:mm:ss').parse(record.clockOut)
                                            )
                                          : 'N/A',
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDuration(record.clockIn, record.clockOut),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
  
  String _formatDuration(String clockIn, String? clockOut) {
    if (clockIn.isEmpty || clockOut == null || clockOut.isEmpty) {
      return '-';
    }
    
    try {
      final inTime = DateFormat('HH:mm:ss').parse(clockIn);
      final outTime = DateFormat('HH:mm:ss').parse(clockOut!);
      
      final duration = outTime.difference(inTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      
      return '$hours hr ${minutes.toString().padLeft(2, '0')} min';
    } catch (e) {
      return '-';
    }
  }
}