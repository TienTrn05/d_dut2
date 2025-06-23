class UserRoleModel {
  final String role;
  final String name;
  final String description;

  UserRoleModel(
      {required this.role, required this.name, required this.description});

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
        role: json['id'], name: json['name'], description: json['description']);
  }
}
