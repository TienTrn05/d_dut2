class UserTypeModel {
  final int id;
  final String name;

  UserTypeModel({required this.id, required this.name});

  factory UserTypeModel.fromJson(Map<String, dynamic> json) {
    return UserTypeModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
