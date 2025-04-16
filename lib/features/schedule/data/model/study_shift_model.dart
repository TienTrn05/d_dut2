class StudyShiftModel {
  final int dayOfWeek;
  final int startPeriod;
  final int endPeriod;
  final int startWeek;
  final int endWeek;
  final String room;

  StudyShiftModel(
      {required this.dayOfWeek,
      required this.startPeriod,
      required this.endPeriod,
      required this.startWeek,
      required this.endWeek,
      required this.room});

  factory StudyShiftModel.fromJson(Map<String, dynamic> json) {
    return StudyShiftModel(
      dayOfWeek: json['dayOfWeek'],
      startPeriod: json['startPeriod'],
      endPeriod: json['endPeriod'],
      startWeek: json['startWeek'],
      endWeek: json['endWeek'],
      room: json['room'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'startPeriod': startPeriod,
      'endPeriod': endPeriod,
      'startWeek': startWeek,
      'endWeek': endWeek,
      'room': room
    };
  }
}
