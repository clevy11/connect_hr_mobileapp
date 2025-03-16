class Employee {
  final int? id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? address;
  final String? dateOfBirth;
  final String? gender;
  final String jobTitle;
  final int? departmentId;
  final int? managerId;
  final String hireDate;
  final double? salary;
  final bool isActive;
  final String? profileImage;
  final String createdAt;
  final String updatedAt;

  Employee({
    this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.gender,
    required this.jobTitle,
    this.departmentId,
    this.managerId,
    required this.hireDate,
    this.salary,
    this.isActive = true,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get full name
  String get fullName => '$firstName $lastName';

  // Convert Employee object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'job_title': jobTitle,
      'department_id': departmentId,
      'manager_id': managerId,
      'hire_date': hireDate,
      'salary': salary,
      'is_active': isActive ? 1 : 0,
      'profile_image': profileImage,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Create an Employee object from a Map
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      dateOfBirth: map['date_of_birth'],
      gender: map['gender'],
      jobTitle: map['job_title'],
      departmentId: map['department_id'],
      managerId: map['manager_id'],
      hireDate: map['hire_date'],
      salary: map['salary'],
      isActive: map['is_active'] == 1,
      profileImage: map['profile_image'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  // Create a copy of Employee with updated fields
  Employee copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? dateOfBirth,
    String? gender,
    String? jobTitle,
    int? departmentId,
    int? managerId,
    String? hireDate,
    double? salary,
    bool? isActive,
    String? profileImage,
    String? createdAt,
    String? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      jobTitle: jobTitle ?? this.jobTitle,
      departmentId: departmentId ?? this.departmentId,
      managerId: managerId ?? this.managerId,
      hireDate: hireDate ?? this.hireDate,
      salary: salary ?? this.salary,
      isActive: isActive ?? this.isActive,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
