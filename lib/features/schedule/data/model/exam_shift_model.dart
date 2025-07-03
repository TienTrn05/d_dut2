class ExamShiftModel {
  final String idExamShift; // Added missing field
  final String noExamGroup;
  final String room;
  final String noExamShift;
  final DateTime examDate;

  ExamShiftModel({
    required this.idExamShift,
    required this.noExamGroup,
    required this.room,
    required this.noExamShift,
    required this.examDate,
  });

  factory ExamShiftModel.fromJson(Map<String, dynamic> json) {
    return ExamShiftModel(
      idExamShift: json['idExamShift'] ?? '',
      noExamGroup: json['noExamGroup'] ?? '',
      room: json['room'] ?? '',
      noExamShift: json['noExamShift'] ?? '',
      examDate: json['examDate'] != null
          ? DateTime.parse(json['examDate'])
          : DateTime.now(), // Provide default if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idExamShift': idExamShift,
      'noExamGroup': noExamGroup,
      'room': room,
      'noExamShift': noExamShift,
      'examDate': examDate.toIso8601String(),
    };
  }
}
