class StudyShiftModel {
  final DateTime studyStartDate;
  final int dayOfWeek;
  final String startStudyTime;
  final int startWeek;
  final int endWeek;
  final String room;

  StudyShiftModel(
      {required this.studyStartDate,
      required this.dayOfWeek,
      required this.startStudyTime,
      required this.startWeek,
      required this.endWeek,
      required this.room});

  factory StudyShiftModel.fromJson(Map<String, dynamic> json) {
    return StudyShiftModel(
        studyStartDate: DateTime.parse(json['studyStartDate']),
        dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 0,
        startStudyTime: json['startStudyTime'] ?? '',
        startWeek: (json['startWeek'] as num?)?.toInt() ?? 0,
        endWeek: (json['endWeek'] as num?)?.toInt() ?? 0,
        room: json['room'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'studyStartDate': studyStartDate.toIso8601String(),
      'dayOfWeek': dayOfWeek,
      'startStudyTime': startStudyTime,
      'startWeek': startWeek,
      'endWeek': endWeek,
      'room': room,
    };
  }
}
