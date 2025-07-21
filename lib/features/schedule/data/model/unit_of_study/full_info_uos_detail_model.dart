import 'package:e_dut/features/schedule/data/model/unit_of_study/exam_shift_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/study_shift_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_detail_model.dart';

class FullInfoUosDetailModel {
  final UosDetailModel uosDetail;
  final String teacherName;
  final int absentTimes;
  final List<StudyShiftModel> studyShifts;
  final ExamShiftModel? examShift;

  FullInfoUosDetailModel(
      {required this.uosDetail,
      required this.teacherName,
      required this.absentTimes,
      required this.studyShifts,
      required this.examShift});

  factory FullInfoUosDetailModel.fromJson(Map<String, dynamic> json) {
    return FullInfoUosDetailModel(
        uosDetail: UosDetailModel.fromJson(json['uosDetail']),
        teacherName: json['teacherName'] ?? '',
        absentTimes: (json['absentTimes'] as int?) ?? 0,
        studyShifts: (json['studyShifts'] as List<dynamic>?)
                ?.map((studyShift) => StudyShiftModel.fromJson(studyShift))
                .toList() ??
            [],
        examShift: json['examShift'] != null
            ? ExamShiftModel.fromJson(json['examShift'])
            : null);
  }
}
