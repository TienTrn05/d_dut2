import 'package:e_dut/features/schedule/data/model/role/teacher_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/exam_shift_model.dart';

class ExamShiftDetailModel {
  final ExamShiftModel examShift;
  final List<TeacherModel> examSupervisors;

  ExamShiftDetailModel({
    required this.examShift,
    required this.examSupervisors,
  });

  factory ExamShiftDetailModel.fromJson(Map<String, dynamic> json) {
    return ExamShiftDetailModel(
      examShift: ExamShiftModel.fromJson(json['examShift']),
      examSupervisors: (json['examSupervisors'] as List<dynamic>?)
              ?.map((supervisor) => TeacherModel.fromJson(supervisor))
              .toList() ??
          [],
    );
  }
}
