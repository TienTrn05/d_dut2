import 'package:e_dut/features/schedule/data/model/exam_shift_model.dart';
import 'package:e_dut/features/schedule/data/model/study_shift_model.dart';

class UosItemModel {
  final String? idUnitOfStudy;
  final String? noUOS;
  final int credit;
  final String subjectName;
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
      idUnitOfStudy: json['idUnitOfStudy'],
      noUOS: json['noUOS'],
      credit: json['credit'],
      subjectName: json['subjectName'],
      teacherName: json['teacherName'],
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

  Map<String, dynamic> toJson() {
    return {
      'idUnitOfStudy': idUnitOfStudy,
      'noUOS': noUOS,
      'credit': credit,
      'subjectName': subjectName,
      'teacherName': teacherName,
      'studyShifts':
          studyShifts.map((studyShift) => studyShift.toJson()).toList(),
      'examShifts': examShifts
          .map((examShift) => examShift.toJson())
          .toList(), // Fixed typo: was 'examShift'
    };
  }
}
