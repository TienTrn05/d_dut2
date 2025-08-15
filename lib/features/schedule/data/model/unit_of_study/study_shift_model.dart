class StudyShiftModel {
  final int dayOfWeek;
  final int startPeriod;
  final int endPeriod;
  final int startWeek;
  final int endWeek;
  final String room;

  StudyShiftModel({
    required this.dayOfWeek,
    required this.startPeriod,
    required this.endPeriod,
    required this.startWeek,
    required this.endWeek,
    required this.room,
  });

  factory StudyShiftModel.fromJson(Map<String, dynamic> json) {
    return StudyShiftModel(
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 0,
      startPeriod: (json['startPeriod'] as num?)?.toInt() ?? 0,
      endPeriod: (json['endPeriod'] as num?)?.toInt() ?? 0,
      startWeek: (json['startWeek'] as num?)?.toInt() ?? 0,
      endWeek: (json['endWeek'] as num?)?.toInt() ?? 0,
      room: json['room'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'startPeriod': startPeriod,
      'endPeriod': endPeriod,
      'startWeek': startWeek,
      'endWeek': endWeek,
      'room': room,
    };
  }
}
