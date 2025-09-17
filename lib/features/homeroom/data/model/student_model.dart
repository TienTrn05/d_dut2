import 'package:e_dut/features/homeroom/data/model/homeroom_model.dart';
import 'package:e_dut/features/homeroom/data/model/program_model.dart';

class StudentModel {
  final String id;
  final String studentCardNumber;
  final String classId;
  final HomeroomModel homeroom;
  final String fullName;
  final int gender;
  final DateTime birthday;
  final String programId;
  final ProgramModel program;
  final String phoneNumber;

  StudentModel(
      {required this.id,
      required this.studentCardNumber,
      required this.classId,
      required this.homeroom,
      required this.fullName,
      required this.gender,
      required this.birthday,
      required this.programId,
      required this.program,
      required this.phoneNumber});

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
        id: json['id'] ?? '',
        studentCardNumber: json['studentCardNumber'] ?? '',
        classId: json['classId'] ?? '',
        homeroom: HomeroomModel.fromJson(json['class']),
        fullName: json['fullName'] ?? '',
        gender: json['gender'] ?? '',
        birthday: DateTime.parse(json['birthday']),
        programId: json['programId'] ?? '',
        program: ProgramModel.fromJson(json['program']),
        phoneNumber: json['phoneNumber'] ?? '');
  }
}
