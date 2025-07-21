class ExamShiftModel {
  final String idExamShift;
  final String examShiftName;
  final String noExamGroup;
  final String room;
  final String noExamShift;
  final DateTime? examDate;
  final String examFormat;
  final String methodOfExam;
  final String examCode;

  ExamShiftModel({
    required this.idExamShift,
    required this.examShiftName,
    required this.noExamGroup,
    required this.room,
    required this.noExamShift,
    required this.examDate,
    required this.examFormat,
    required this.methodOfExam,
    required this.examCode,
  });

  factory ExamShiftModel.fromJson(Map<String, dynamic> json) {
    return ExamShiftModel(
        idExamShift: json['idExamShift'] ?? '',
        examShiftName: json['examShiftName'] ?? '',
        noExamGroup: json['noExamGroup'] ?? '',
        room: json['room'] ?? '',
        noExamShift: json['noExamShift'] ?? '',
        examDate:
            json['examDate'] != null ? DateTime.parse(json['examDate']) : null,
        examFormat: json['examFormat'] ?? '',
        methodOfExam: json['methodOfExam'] ?? '',
        examCode: json['examCode'] ?? '');
  }
  @override
  String toString() {
    return 'ExamShiftModel(idExamShift: $idExamShift, examDate: $examDate, room: $room)';
  }
}
