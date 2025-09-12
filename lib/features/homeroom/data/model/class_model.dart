class ClassModel {
  final String id;
  final String name;
  final String programId;
  final String scheduleGroup;
  final String enrollmentYear;

  ClassModel(
      {required this.id,
      required this.name,
      required this.programId,
      required this.scheduleGroup,
      required this.enrollmentYear});

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        programId: json['programId'] ?? '',
        scheduleGroup: json['scheduleGroup'] ?? '',
        enrollmentYear: json['enrollmentYear'] ?? '');
  }
}
