import 'package:e_dut/features/schedule/data/model/role/student_absent_model.dart';

class UosStudentsAbsentModel {
  final String idUnitOfStudy;
  final String subjectName;
  final int studentsQuantity;
  final int absentStudentsQuantity;
  final List<StudentAbsentModel> students;

  UosStudentsAbsentModel(
      {required this.idUnitOfStudy,
      required this.subjectName,
      required this.studentsQuantity,
      required this.absentStudentsQuantity,
      required this.students});

  factory UosStudentsAbsentModel.fromJson(Map<String, dynamic> json) {
    return UosStudentsAbsentModel(
        idUnitOfStudy: json['idUnitOfStudy'] ?? '',
        subjectName: json['subjectName'] ?? '',
        studentsQuantity: (json['studentsQuantity'] as int?) ?? 0,
        absentStudentsQuantity: (json['absentStudentsQuantity'] as int?) ?? 0,
        students: (json['students'] as List<dynamic>?)
                ?.map((item) => StudentAbsentModel.fromJson(item))
                .toList() ??
            []);
  }
}
