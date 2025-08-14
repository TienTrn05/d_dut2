import 'package:e_dut/features/schedule/data/model/role/student_model.dart';

class StudentsExamShiftModel {
  final String idExamShift;
  final String examShiftName;
  final int studentQuantity;
  final List<StudentModel> students;

  StudentsExamShiftModel(
      {required this.idExamShift,
      required this.examShiftName,
      required this.studentQuantity,
      required this.students});

  factory StudentsExamShiftModel.fromJson(Map<String, dynamic> json) {
    return StudentsExamShiftModel(
        idExamShift: json['idExamShift'] ?? '',
        examShiftName: json['examShiftName'] ?? '',
        studentQuantity: (json['studentsQuantity'] as int?) ?? 0,
        students: (json['students'] as List<dynamic>?)
                ?.map((item) => StudentModel.fromJson(item))
                .toList() ??
            []);
  }
}
