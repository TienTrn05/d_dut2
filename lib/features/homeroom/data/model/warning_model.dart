class WarningModel {
  final String semesterCode;
  final int warningLevel;

  WarningModel({required this.semesterCode, required this.warningLevel});

  factory WarningModel.fromJson(Map<String, dynamic> json) {
    return WarningModel(
      semesterCode: json['semesterCode']?.toString() ?? '',
      warningLevel: json['warningLevel'] ?? 0,
    );
  }

  // "192" -> "HK2, 2019 - 2020"
  String get formattedSemester {
    if (semesterCode.length >= 3) {
      String yearStr = semesterCode.substring(0, 2);
      String semStr = semesterCode.substring(2);

      int startYear = int.parse("20$yearStr");
      int endYear = startYear + 1;

      return "HK$semStr, $startYear - $endYear";
    }
    return semesterCode;
  }
}
