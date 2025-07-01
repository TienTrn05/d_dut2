class FacultyModel {
  final String id;
  final String code;
  final String name;

  FacultyModel({required this.id, required this.code, required this.name});

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(id: json['id'], code: json['code'], name: json['name']);
  }
}
