import 'package:e_dut/features/schedule/data/model/unit_of_study/exam_shift_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/study_shift_model.dart';

class UosItemModel {
  final String? idUnitOfStudy;
  final String? noUOS;
  final num credit;
  final String? subjectName;
  final String? teacherName;
  final List<StudyShiftModel> studyShifts;
  final List<ExamShiftModel> examShifts;

  UosItemModel({
    this.idUnitOfStudy,
    this.noUOS,
    required this.credit,
    required this.subjectName,
    this.teacherName,
    required this.studyShifts,
    required this.examShifts,
  });

  factory UosItemModel.fromJson(Map<String, dynamic> json) {
    return UosItemModel(
      idUnitOfStudy: json['idUnitOfStudy'] ?? '',
      noUOS: json['noUOS'] ?? '',
      credit: (json['credit'] as num?) ?? 0,
      subjectName: json['subjectName'] ?? '',
      teacherName: json['teacherName'] ?? '',
      studyShifts: (json['studyShifts'] as List<dynamic>?)
              ?.map((studyShift) => StudyShiftModel.fromJson(studyShift))
              .toList() ??
          [],
      examShifts: (json['examShifts'] as List<dynamic>?)
              ?.map((examShift) => ExamShiftModel.fromJson(examShift))
              .toList() ??
          [],
    );
  }
}
