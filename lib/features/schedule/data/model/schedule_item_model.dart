class ScheduleItemModel {
  final String idUnitOfStudy;
  final String idExamShift;
  final String subjectName;
  final String room;
  final String startStudyTime;
  final String endStudyTime;
  final DateTime? examTime;
  final bool isExam;
  final String noExamShift;
  final String examShiftName;
  final String noExamGroup;

  ScheduleItemModel({
    required this.idUnitOfStudy,
    required this.idExamShift,
    required this.subjectName,
    required this.room,
    required this.startStudyTime,
    required this.endStudyTime,
    required this.examTime,
    required this.noExamShift,
    required this.examShiftName,
    required this.noExamGroup,
    this.isExam = false,
  })  : assert(
          // Ràng buộc thời gian học hoặc thời gian thi
          (isExam && examTime != null && idExamShift.isNotEmpty) ||
              (!isExam && startStudyTime.isNotEmpty && endStudyTime.isNotEmpty),
          'Invalid schedule data: For exam, examTime and idExamShift are required. For study, startStudyTime and endStudyTime are required.',
        ),
        assert(
          // Ràng buộc phải có ít nhất 1 trong 2 id
          idUnitOfStudy.isNotEmpty || idExamShift.isNotEmpty,
          'Invalid schedule data: Must have at least one of idUnitOfStudy or idExamShift.',
        );

  factory ScheduleItemModel.fromJson(Map<String, dynamic> json) {
    final bool isExam = json['isExam'] == true;
    final String startStudyTime = json['startStudyTime'] ?? '';
    final String endStudyTime = json['endStudyTime'] ?? '';
    final DateTime? examTime =
        json['examTime'] != null ? DateTime.tryParse(json['examTime']) : null;

    final String idUnitOfStudy = json['idUnitOfStudy'] ?? '';
    final String idExamShift = json['idExamShift'] ?? '';

    // Sửa lại logic validation
    if (isExam && (examTime == null || idExamShift.isEmpty)) {
      throw Exception("isExam = true nhưng thiếu examTime hoặc idExamShift");
    }
    if (!isExam && (startStudyTime.isEmpty || endStudyTime.isEmpty)) {
      throw Exception("isExam = false nhưng thiếu thời gian học");
    }
    if (idUnitOfStudy.isEmpty && idExamShift.isEmpty) {
      throw Exception(
          "Phải có ít nhất 1 trong 2: idUnitOfStudy hoặc idExamShift");
    }

    return ScheduleItemModel(
      idUnitOfStudy: idUnitOfStudy,
      idExamShift: idExamShift,
      subjectName: json['subjectName'] ?? '',
      room: json['room'] ?? '',
      startStudyTime: startStudyTime,
      endStudyTime: endStudyTime,
      examTime: examTime,
      isExam: isExam,
      noExamShift: json['noExamShift'] ?? '',
      examShiftName: json['examShiftName'] ?? '',
      noExamGroup: json['noExamGroup'] ?? '',
    );
  }
}
