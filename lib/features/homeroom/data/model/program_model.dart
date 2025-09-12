import 'package:e_dut/features/homeroom/data/model/major_model.dart';

class ProgramModel {
  final String id;
  final String academicProgramName;
  final String academicProgramNameEn;
  final MajorModel major;
  final int credits;
  final int electiveCredits;
  final int semesters;
  final DateTime startDate;
  final DateTime endDate;
  final String educationLevel;
  final bool isDeleted;

  ProgramModel(
      {required this.id,
      required this.academicProgramName,
      required this.academicProgramNameEn,
      required this.major,
      required this.credits,
      required this.electiveCredits,
      required this.semesters,
      required this.startDate,
      required this.endDate,
      required this.educationLevel,
      required this.isDeleted});

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
        id: json['id'] ?? '',
        academicProgramName: json['academicProgramName'] ?? '',
        academicProgramNameEn: json['academicProgramNameEn'] ?? '',
        major: MajorModel.fromJson(json['major']),
        credits: json['credits'] ?? 0,
        electiveCredits: json['electiveCredits'] ?? 0,
        semesters: json['semesters'] ?? 0,
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        educationLevel: json['educationLevel'] ?? '',
        isDeleted: json['isDeleted']);
  }
}
