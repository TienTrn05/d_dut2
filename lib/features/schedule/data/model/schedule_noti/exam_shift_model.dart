class ExamShiftModel {
  final String idExamShift;
  final String examShiftName;
  final String room;
  final DateTime? examDate;
  final String examCode;

  ExamShiftModel(
      {required this.idExamShift,
      required this.examShiftName,
      required this.room,
      required this.examDate,
      required this.examCode});

  factory ExamShiftModel.fromJson(Map<String, dynamic> json) {
    return ExamShiftModel(
        idExamShift: json['idExamShift'] ?? '',
        examShiftName: json['examShiftName'] ?? '',
        room: json['room'] ?? '',
        examDate:
            json['examDate'] != null ? DateTime.parse(json['examDate']) : null,
        examCode: json['examCode'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'idExamShift': idExamShift,
      'examShiftName': examShiftName,
      'room': room,
      'examDate': examDate?.toIso8601String(),
      'examCode': examCode,
    };
  }
}
