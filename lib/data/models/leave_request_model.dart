class LeaveRequest {
  final int? id;
  final int employeeId;
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final String appliedDate;
  final int? approvedBy;
  final String? approvedDate;

  LeaveRequest({
    this.id,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.appliedDate,
    this.approvedBy,
    this.approvedDate,
  });

  // Convert LeaveRequest object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'leave_type': leaveType,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
      'status': status,
      'applied_date': appliedDate,
      'approved_by': approvedBy,
      'approved_date': approvedDate,
    };
  }

  // Create a LeaveRequest object from a Map
  factory LeaveRequest.fromMap(Map<String, dynamic> map) {
    return LeaveRequest(
      id: map['id'],
      employeeId: map['employee_id'],
      leaveType: map['leave_type'],
      startDate: map['start_date'],
      endDate: map['end_date'],
      reason: map['reason'],
      status: map['status'],
      appliedDate: map['applied_date'],
      approvedBy: map['approved_by'],
      approvedDate: map['approved_date'],
    );
  }

  // Create a copy of LeaveRequest with updated fields
  LeaveRequest copyWith({
    int? id,
    int? employeeId,
    String? leaveType,
    String? startDate,
    String? endDate,
    String? reason,
    String? status,
    String? appliedDate,
    int? approvedBy,
    String? approvedDate,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedDate: approvedDate ?? this.approvedDate,
    );
  }
}
