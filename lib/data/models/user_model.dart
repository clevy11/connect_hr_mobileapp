class User {
  final int? id;
  final String username;
  final String password;
  final String role;
  final int? employeeId;
  final String createdAt;
  final String? lastLogin;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    this.employeeId,
    required this.createdAt,
    this.lastLogin,
  });

  // Convert User object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'employee_id': employeeId,
      'created_at': createdAt,
      'last_login': lastLogin,
    };
  }

  // Create a User object from a Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
      employeeId: map['employee_id'],
      createdAt: map['created_at'],
      lastLogin: map['last_login'],
    );
  }

  // Create a copy of User with updated fields
  User copyWith({
    int? id,
    String? username,
    String? password,
    String? role,
    int? employeeId,
    String? createdAt,
    String? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
