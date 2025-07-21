class TeacherModel {
  final String idTeacher;
  final String noTeacher;
  final String teacherName;

  TeacherModel(
      {required this.idTeacher,
      required this.noTeacher,
      required this.teacherName});

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
        idTeacher: json['idTeacher'],
        noTeacher: json['noTeacher'],
        teacherName: json['teacherName']);
  }
}
