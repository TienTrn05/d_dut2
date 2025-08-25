import 'package:e_dut/features/schedule/data/model/schedule_noti/exam_shift_model.dart';
import 'package:e_dut/features/schedule/data/model/schedule_noti/study_shift_model.dart';

class UosModel {
  final String idUnitOfStudy;
  final String noUOS;
  final String subjectName;
  final List<StudyShiftModel> studyShifts;
  final List<ExamShiftModel> examShifts;

  UosModel(
      {required this.idUnitOfStudy,
      required this.noUOS,
      required this.subjectName,
      required this.studyShifts,
      required this.examShifts});

  factory UosModel.fromJson(Map<String, dynamic> json) {
    return UosModel(
        idUnitOfStudy: json['idUnitOfStudy'] ?? '',
        noUOS: json['noUOS'] ?? '',
        subjectName: json['subjectName'] ?? '',
        studyShifts: (json['studyShifts'] as List<dynamic>?)
                ?.map((studyShift) => StudyShiftModel.fromJson(studyShift))
                .toList() ??
            [],
        examShifts: (json['examShifts'] as List<dynamic>?)
                ?.map((examShift) => ExamShiftModel.fromJson(examShift))
                .toList() ??
            []);
  }

  Map<String, dynamic> toJson() {
    return {
      'idUnitOfStudy': idUnitOfStudy,
      'noUOS': noUOS,
      'subjectName': subjectName,
      'studyShifts': studyShifts.map((shift) => shift.toJson()).toList(),
      'examShifts': examShifts.map((shift) => shift.toJson()).toList(),
    };
  }
}
