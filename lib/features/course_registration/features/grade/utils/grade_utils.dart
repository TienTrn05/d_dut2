import 'package:e_dut/features/course_registration/features/grade/data/models/grade_color.dart';
import 'package:flutter/material.dart';

class GradeUtils {
  static String getSemesterStr(String semesterCode) {
    if (semesterCode.length != 4) {
      return "Kỳ học không hợp lệ";
    }

    final yearCode = semesterCode.substring(0, 2);

    final semester = semesterCode.substring(2, 4);

    var semesterStr = "";
    if (semester == "10") {
      semesterStr = "1";
    } else if (semester == "20") {
      semesterStr = "2";
    } else if (semester == "21") {
      semesterStr = "Hè";
    }

    return "Học kỳ $semesterStr, 20$yearCode-20${int.parse(yearCode) + 1}";
  }

  static GradeColor getGradeColor(String letterGrade) {
    final grade = letterGrade.toUpperCase();

    if (grade.startsWith('A')) {
      return GradeColor(
        background: const Color(0xFFDCFCE7),
        text: const Color(0xFF1B5E20),
      );
    } else if (grade.startsWith('B')) {
      return GradeColor(
        background: const Color(0xFFE3F2FD),
        text: const Color(0xFF0D47A1),
      );
    } else if (grade == 'C') {
      return GradeColor(
        background: const Color(0xFFFFF9C4),
        text: const Color(0xFFF9A825),
      );
    } else if (grade == 'D') {
      return GradeColor(
        background: const Color(0xFFFFE0B2),
        text: const Color(0xFFEF6C00),
      );
    } else if (grade == 'F') {
      return GradeColor(
        background: const Color(0xFFFFCDD2),
        text: const Color(0xFFC62828),
      );
    }

    return GradeColor(
      background: Colors.grey.shade200,
      text: Colors.black,
    );
  }
}
