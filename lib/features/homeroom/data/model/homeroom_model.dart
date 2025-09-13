class HomeroomModel {
  final String id;
  final String name;
  final String programId;
  final String scheduleGroup;
  final String enrollmentYear;
  final int numOfStudents;

  HomeroomModel(
      {required this.id,
      required this.name,
      required this.programId,
      required this.scheduleGroup,
      required this.enrollmentYear,
      required this.numOfStudents});

  factory HomeroomModel.fromJson(Map<String, dynamic> json) {
    return HomeroomModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        programId: json['programId'] ?? '',
        scheduleGroup: json['scheduleGroup'] ?? '',
        enrollmentYear: json['enrollmentYear'] ?? '',
        numOfStudents: json['numOfStudents'] ?? 0);
  }
}
