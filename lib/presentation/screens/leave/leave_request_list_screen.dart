import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/leave_request_model.dart';
import '../../providers/auth_provider.dart';

class LeaveRequestListScreen extends StatefulWidget {
  const LeaveRequestListScreen({Key? key}) : super(key: key);

  @override
  State<LeaveRequestListScreen> createState() => _LeaveRequestListScreenState();
}

class _LeaveRequestListScreenState extends State<LeaveRequestListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<LeaveRequest> _leaveRequests = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLeaveRequests();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadLeaveRequests() async {
    setState(() {
      _isLoading = true;
    });
    
    // In a real app, this would fetch from the repository
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample data
    final now = DateTime.now();
    final sampleLeaveRequests = [
      LeaveRequest(
        id: 1,
        employeeId: 1,
        leaveType: 'Annual Leave',
        startDate: DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 5))),
        endDate: DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 10))),
        reason: 'Family vacation',
        status: AppConstants.leaveStatusPending,
        appliedDate: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 2))),
        approvedBy: null,
        approvedDate: null,
      ),
      LeaveRequest(
        id: 2,
        employeeId: 1,
        leaveType: 'Sick Leave',
        startDate: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 10))),
        endDate: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 8))),
        reason: 'Flu and fever',
        status: AppConstants.leaveStatusApproved,
        appliedDate: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 15))),
        approvedBy: 2,
        approvedDate: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 14))),
      ),
      LeaveRequest(
        id: 3,
        employeeId: 1,
        leaveType: 'Personal Leave',
        startDate: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 20))),
        endDate: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 20))),
        reason: 'Family emergency',
        status: AppConstants.leaveStatusApproved,
        appliedDate: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 21))),
        approvedBy: 2,
        approvedDate: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 21))),
      ),
      LeaveRequest(
        id: 4,
        employeeId: 1,
        leaveType: 'Annual Leave',
        startDate: DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 15))),
        endDate: DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 16))),
        reason: 'Personal event',
        status: AppConstants.leaveStatusRejected,
        appliedDate: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 5))),
        approvedBy: 2,
        approvedDate: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 3))),
      ),
      LeaveRequest(
        id: 5,
        employeeId: 1,
        leaveType: 'Sick Leave',
        startDate: DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 1))),
        endDate: DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 2))),
        reason: 'Medical appointment',
        status: AppConstants.leaveStatusPending,
        appliedDate: DateFormat('yyyy-MM-dd').format(now),
        approvedBy: null,
        approvedDate: null,
      ),
    ];
    
    if (mounted) {
      setState(() {
        _leaveRequests = sampleLeaveRequests;
        _isLoading = false;
      });
    }
  }
  
  List<LeaveRequest> _getFilteredLeaveRequests(String status) {
    if (status == 'all') {
      return _leaveRequests;
    }
    return _leaveRequests.where((request) => request.status == status).toList();
  }
  
  void _showLeaveRequestDetails(LeaveRequest leaveRequest) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: leaveRequest.status == AppConstants.leaveStatusApproved
                        ? AppTheme.successColor
                        : leaveRequest.status == AppConstants.leaveStatusRejected
                            ? AppTheme.dangerColor
                            : AppTheme.warningColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    leaveRequest.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  leaveRequest.leaveType,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              _buildDetailItem(Icons.calendar_today, 'Duration', 
                '${DateFormat('MMM d, yyyy').format(DateFormat('yyyy-MM-dd').parse(leaveRequest.startDate))} - '
                '${DateFormat('MMM d, yyyy').format(DateFormat('yyyy-MM-dd').parse(leaveRequest.endDate))}'),
              _buildDetailItem(Icons.access_time, 'Applied On', 
                DateFormat('MMM d, yyyy').format(DateFormat('yyyy-MM-dd').parse(leaveRequest.appliedDate))),
              if (leaveRequest.approvedDate != null)
                _buildDetailItem(Icons.check_circle, 'Processed On', 
                  DateFormat('MMM d, yyyy').format(DateFormat('yyyy-MM-dd').parse(leaveRequest.approvedDate!))),
              _buildDetailItem(Icons.note, 'Reason', leaveRequest.reason),
              const SizedBox(height: 16),
              if (leaveRequest.status == AppConstants.leaveStatusPending && (authProvider.isAdmin || authProvider.isHrManager))
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _updateLeaveRequestStatus(leaveRequest, AppConstants.leaveStatusApproved);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _updateLeaveRequestStatus(leaveRequest, AppConstants.leaveStatusRejected);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.dangerColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _updateLeaveRequestStatus(LeaveRequest leaveRequest, String status) async {
    setState(() {
      _isLoading = true;
    });
    
    // In a real app, this would call the repository
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        final index = _leaveRequests.indexWhere((request) => request.id == leaveRequest.id);
        if (index != -1) {
          _leaveRequests[index] = leaveRequest.copyWith(
            status: status,
            approvedBy: 2, // Current user ID
            approvedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          );
        }
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave request ${status.toLowerCase()}'),
          backgroundColor: status == AppConstants.leaveStatusApproved
              ? AppTheme.successColor
              : AppTheme.dangerColor,
        ),
      );
    }
  }
  
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
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
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.titleLeaveRequests),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Processed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaveRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // All Tab
                _buildLeaveRequestList(_getFilteredLeaveRequests('all')),
                
                // Pending Tab
                _buildLeaveRequestList(_getFilteredLeaveRequests(AppConstants.leaveStatusPending)),
                
                // Processed Tab
                _buildLeaveRequestList(_leaveRequests.where(
                  (request) => request.status == AppConstants.leaveStatusApproved || 
                              request.status == AppConstants.leaveStatusRejected
                ).toList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create leave request screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildLeaveRequestList(List<LeaveRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No leave requests found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadLeaveRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          final startDate = DateFormat('yyyy-MM-dd').parse(request.startDate);
          final endDate = DateFormat('yyyy-MM-dd').parse(request.endDate);
          final duration = endDate.difference(startDate).inDays + 1;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _showLeaveRequestDetails(request),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          request.leaveType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: request.status == AppConstants.leaveStatusApproved
                                ? AppTheme.successColor
                                : request.status == AppConstants.leaveStatusRejected
                                    ? AppTheme.dangerColor
                                    : AppTheme.warningColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            request.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)} ($duration ${duration > 1 ? 'days' : 'day'})',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.note,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            request.reason,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Applied on ${DateFormat('MMM d, yyyy').format(DateFormat('yyyy-MM-dd').parse(request.appliedDate))}',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
