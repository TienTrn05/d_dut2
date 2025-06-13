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
    }else if (semester == "21") {
      semesterStr = "Hè";
    }

    return "Học kỳ $semesterStr, 20$yearCode-20${int.parse(yearCode) + 1}";
  }
}