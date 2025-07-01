import 'package:e_dut/features/community_activity/data/model/faculty_model.dart';

class ClazzModel {
  final String id;
  final String name;
  final FacultyModel faculty;

  ClazzModel({required this.id, required this.name, required this.faculty});

  factory ClazzModel.fromjson(Map<String, dynamic> json) {
    return ClazzModel(
        id: json['id'],
        name: json['name'],
        faculty: FacultyModel.fromJson(json['faculty']));
  }
}
