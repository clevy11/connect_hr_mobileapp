class Attendance {
  final int? id;
  final int employeeId;
  final String date;
  final String clockIn;
  final String clockOut;
  final String status;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  Attendance({
    this.id,
    required this.employeeId,
    required this.date,
    required this.clockIn,
    this.clockOut = '',
    required this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Attendance object to a Map
  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'employee_id': employeeId,
      'date': date,
      'clock_in': clockIn,
      'clock_out': clockOut,
      'status': status,
      'notes': notes,
    };
    
    if (createdAt != null) {
      map['created_at'] = createdAt;
    }
    
    if (updatedAt != null) {
      map['updated_at'] = updatedAt;
    }
    
    return map;
  }

  // Create an Attendance object from a Map
  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      employeeId: map['employee_id'],
      date: map['date'],
      clockIn: map['clock_in'] ?? '',
      clockOut: map['clock_out'] ?? '',
      status: map['status'],
      notes: map['notes'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  // Create a copy of the Attendance object with some changes
  Attendance copyWith({
    int? id,
    int? employeeId,
    String? date,
    String? clockIn,
    String? clockOut,
    String? status,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
