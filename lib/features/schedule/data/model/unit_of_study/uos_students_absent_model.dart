import 'package:e_dut/features/schedule/data/model/unit_of_study/students_paged_absent_model.dart';

class UosStudentsAbsentModel {
  final String idExamShift;
  final String examShiftName;
  final int studentQuantity;
  final StudentsPagedAbsentModel studentsPaged;

  UosStudentsAbsentModel(
      {required this.idExamShift,
      required this.examShiftName,
      required this.studentQuantity,
      required this.studentsPaged});

  factory UosStudentsAbsentModel.fromJson(Map<String, dynamic> json) {
    return UosStudentsAbsentModel(
        idExamShift: json['idExamShift'] ?? '',
        examShiftName: json['examShiftName'] ?? '',
        studentQuantity: (json['studentsQuantity'] as int?) ?? 0,
        studentsPaged:
            StudentsPagedAbsentModel.fromJson(json['studentsPaged']));
  }
}
