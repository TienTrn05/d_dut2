class ExamShiftModel {
  final String noExamGroup;
  final String room;
  final String noExamShift;
  final DateTime examDate;

  ExamShiftModel(
      {required this.noExamGroup,
      required this.room,
      required this.noExamShift,
      required this.examDate});

  factory ExamShiftModel.fromJson(Map<String, dynamic> json) {
    return ExamShiftModel(
        noExamGroup: json['noExamGroup'],
        room: json['room'],
        noExamShift: json['noExamShift'],
        examDate: DateTime.parse(json['examDate']));
  }

  Map<String, dynamic> toJson() {
    return {
      'noExamGroup': noExamGroup,
      'room': room,
      'noExamShift': noExamShift,
      'examDate': examDate.toIso8601String(),
    };
  }
}
