class StudentModel {
  final String idStudent;
  final String noStudent;
  final String dutAccount;
  final String studentName;

  StudentModel(
      {required this.idStudent,
      required this.noStudent,
      required this.dutAccount,
      required this.studentName});

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
        idStudent: json['idStudent'] ?? '',
        noStudent: json['noStudent'] ?? '',
        dutAccount: json['dutAccount'] ?? '',
        studentName: json['studentName'] ?? '');
  }
}
