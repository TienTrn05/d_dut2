import 'package:e_dut/features/homeroom/data/model/homeroom_model.dart';
import 'package:e_dut/features/homeroom/data/model/program_model.dart';
import 'package:e_dut/features/homeroom/data/model/warning_model.dart';

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
  final List<WarningModel> warnings;

  StudentModel({
    required this.id,
    required this.studentCardNumber,
    required this.classId,
    required this.homeroom,
    required this.fullName,
    required this.gender,
    required this.birthday,
    required this.programId,
    required this.program,
    required this.phoneNumber,
    required this.warnings,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    var warningsList = json['warnings'] as List? ?? [];
    List<WarningModel> parsedWarnings =
        warningsList.map((w) => WarningModel.fromJson(w)).toList();

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
      phoneNumber: json['phoneNumber'] ?? '',
      warnings: parsedWarnings,
    );
  }

  String get computedStatus {
    if (warnings.isEmpty) return 'Bình thường';

    if (warnings.any((w) => w.warningLevel == 3)) return 'Ngừng học';
    if (warnings.any((w) => w.warningLevel == 2)) return 'Buộc thôi học';

    int level1Count = warnings.where((w) => w.warningLevel == 1).length;
    if (level1Count >= 2) return 'Cảnh báo (Lần 2)';
    if (level1Count == 1) return 'Cảnh báo (Lần 1)';

    return 'Bình thường';
  }

  // Trạng thái hiển thị chi tiết cho Dialog (Kèm kỳ học mới nhất)
  String get detailedStatus {
    String status = computedStatus;
    if (status.contains('Cảnh báo') && warnings.isNotEmpty) {
      // Sắp xếp để lấy cảnh báo có mã kỳ học lớn nhất (mới nhất)
      var sorted = List<WarningModel>.from(warnings)
        ..sort((a, b) => a.semesterCode.compareTo(b.semesterCode));
      var latest = sorted.last;
      return "$status: ${latest.formattedSemester}";
    }
    return status; // Trả về dạng rút gọn nếu là "Ngừng học", "Buộc thôi học"
  }
}
