class SemesterModel {
  final String idSemester;
  final String noSemester;
  final int startYear;
  final int endYear;
  final bool isCurrentSemester;

  SemesterModel(
      {required this.idSemester,
      required this.noSemester,
      required this.startYear,
      required this.endYear,
      this.isCurrentSemester = false});

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
        idSemester: json['idSemester'],
        noSemester: json['noSemester'],
        startYear: json['startYear'],
        endYear: json['endYear']);
  }

  Map<String, dynamic> toJson() {
    return {
      'idSemester': idSemester,
      'noSemester': noSemester,
      'startYear': startYear,
      'endYear': endYear
    };
  }
}
