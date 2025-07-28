class StudentAbsentModel {
  final String idStudent;
  final String noStudent;
  final String studentName;
  final int absentTimes;
  final bool isAbsent;

  StudentAbsentModel({
    required this.idStudent,
    required this.noStudent,
    required this.studentName,
    required this.absentTimes,
    required this.isAbsent,
  });

  factory StudentAbsentModel.fromJson(Map<String, dynamic> json) {
    return StudentAbsentModel(
      idStudent: json['idStudent'] ?? '',
      noStudent: json['noStudent'] ?? '',
      studentName: json['studentName'] ?? '',
      absentTimes: json['absentTimes'] ?? 0,
      isAbsent: json['isAbsent'] ?? false,
    );
  }
}
