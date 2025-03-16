class Department {
  final int? id;
  final String name;
  final String? description;
  final String createdAt;

  Department({
    this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  // Convert Department object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
    };
  }

  // Create a Department object from a Map
  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: map['created_at'],
    );
  }

  // Create a copy of Department with updated fields
  Department copyWith({
    int? id,
    String? name,
    String? description,
    String? createdAt,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
