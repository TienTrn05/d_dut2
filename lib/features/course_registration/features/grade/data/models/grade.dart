class Grade {
  final String id;
  final String courseName;
  final String semesterCode;
  final int credits;
  final String courseSectionCode;
  final double score10Scale;
  final String letterGrade;
  final double score4Scale;

  Grade({
    required this.id,
    required this.courseName,
    required this.semesterCode,
    required this.credits,
    required this.courseSectionCode,
    required this.score10Scale,
    required this.letterGrade,
    required this.score4Scale,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      courseName: json['course']['courseName'],
      semesterCode: json['semesterCode'],
      credits: json['course']['credits'] as int,
      courseSectionCode: json['courseSectionCode'],
      score10Scale: (json['score10Scale'] as num).toDouble(),
      letterGrade: json['letterGrade'],
      score4Scale: (json['score4Scale'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
