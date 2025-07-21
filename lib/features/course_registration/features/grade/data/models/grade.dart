import 'dart:collection';

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
      courseName: json['courseName'],
      semesterCode: json['semesterCode'],
      credits: json['credits'] as int,
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

  static Map<String, List<Grade>> groupBySemesterCode(List<Grade> grades) {
    final Map<String, List<Grade>> grouped = {};

    for (final grade in grades) {
      final group = grade.semesterCode;
      if (grouped.containsKey(group)) {
        grouped[group]!.add(grade);
      } else {
        grouped[group] = [grade];
      }
    }

    // Sort the keys (semesterCodes)
    final sortedKeys = grouped.keys.toList()..sort();

    // Build a LinkedHashMap to preserve the sorted order
    final sortedGrouped = LinkedHashMap<String, List<Grade>>(
      equals: (a, b) => a == b,
      hashCode: (key) => key.hashCode,
    );

    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }
}
