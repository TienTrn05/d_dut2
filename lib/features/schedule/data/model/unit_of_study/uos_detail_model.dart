class UosDetailModel {
  final String idUnitOfStudy;
  final String subjectName;
  final String noUOS;
  final String noSubject;
  final int clc;
  final num credit;
  final String semester;
  final String methodOfTeaching;
  final String msTeamCode;
  final String msTeamLink;
  final String scoreFormula;

  UosDetailModel(
      {required this.idUnitOfStudy,
      required this.subjectName,
      required this.noUOS,
      required this.noSubject,
      required this.clc,
      required this.credit,
      required this.semester,
      required this.methodOfTeaching,
      required this.msTeamCode,
      required this.msTeamLink,
      required this.scoreFormula});

  factory UosDetailModel.fromJson(Map<String, dynamic> json) {
    return UosDetailModel(
        idUnitOfStudy: json['idUnitOfStudy'] ?? '',
        subjectName: json['subjectName'] ?? '',
        noUOS: json['noUOS'] ?? '',
        noSubject: json['noSubject'] ?? '',
        clc: (json['clc'] as int?) ?? 0,
        credit: (json['credit'] as num?) ?? 0,
        semester: json['semester'] ?? '',
        methodOfTeaching: json['methodOfTeaching'] ?? '',
        msTeamCode: json['msTeamCode'] ?? '',
        msTeamLink: json['msTeamLink'] ?? '',
        scoreFormula: json['scoreFormula'] ?? '');
  }
}
