class Course {
  final String id;
  final String courseName;
  final int credits;
  final String courseShortName;
  final bool isOpenToOtherMajors;
  final String facultyId;

  Course({
    required this.id,
    required this.courseName,
    required this.credits,
    required this.courseShortName,
    required this.isOpenToOtherMajors,
    required this.facultyId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      courseName: json['courseName'],
      credits: json['credits'],
      courseShortName: json['courseShortName'],
      isOpenToOtherMajors: json['isOpenToOtherMajors'] ?? false,
      facultyId: json['facultyId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseName': courseName,
      'credits': credits,
      'courseShortName': courseShortName,
      'isOpenToOtherMajors': isOpenToOtherMajors,
      'facultyId': facultyId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
