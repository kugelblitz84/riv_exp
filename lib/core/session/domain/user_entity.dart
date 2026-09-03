enum Role { admin, agent, customer }

class UserModel {
  final String id;
  final String email;
  final String name;
  final Role role;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  UserModel copyWith({String? id, String? email, String? name, Role? role}) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: _parseRole(json['role'] as String?),
    );
  }

  static Role _parseRole(String? role) {
    return switch (role?.toLowerCase()) {
      'admin' => Role.admin,
      'agent' => Role.agent,
      _ => Role.customer,
    };
  }
}
