import 'package:e_dut/features/schedule/data/model/unit_of_study/students_paged_model.dart';

class StudentsExamShiftModel {
  final String idExamShift;
  final String examShiftName;
  final int studentQuantity;
  final StudentsPagedModel studentsPaged;

  StudentsExamShiftModel(
      {required this.idExamShift,
      required this.examShiftName,
      required this.studentQuantity,
      required this.studentsPaged});

  factory StudentsExamShiftModel.fromJson(Map<String, dynamic> json) {
    return StudentsExamShiftModel(
        idExamShift: json['idExamShift'] ?? '',
        examShiftName: json['examShiftName'] ?? '',
        studentQuantity: (json['studentsQuantity'] as int?) ?? 0,
        studentsPaged: StudentsPagedModel.fromJson(json['studentsPaged']));
  }
}
