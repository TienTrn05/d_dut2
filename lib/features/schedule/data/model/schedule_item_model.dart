class ScheduleItemModel {
  final String idUnitOfStudy;
  final String subjectName;
  final String room;
  final String? startStudyTime;
  final String? endStudyTime;
  final DateTime? examTime;
  final bool isExam;
  final String? noExamShift;
  final String? noExamGroup;

  ScheduleItemModel(
      {required this.idUnitOfStudy,
      required this.subjectName,
      required this.room,
      this.startStudyTime,
      this.endStudyTime,
      this.examTime,
      this.noExamShift,
      this.noExamGroup,
      this.isExam = false})
      : assert(
          (isExam && examTime != null) ||
              (!isExam && startStudyTime != null && endStudyTime != null),
          'Invalid schedule data: Either examTime or studyTime must be provided depending on isExam.',
        );

  factory ScheduleItemModel.fromJson(Map<String, dynamic> json) {
    final bool isExam = json['isExam'] == true;
    final String? startStudyTime = json['startStudyTime'];
    final String? endStudyTime = json['endStudyTime'];
    final DateTime? examTime =
        json['examTime'] != null ? DateTime.tryParse(json['examTime']) : null;

    // Ràng buộc logic dữ liệu hợp lệ
    if (isExam && examTime == null) {
      throw Exception("isExam = true nhưng không có examTime");
    }
    if (!isExam && (startStudyTime == null || endStudyTime == null)) {
      throw Exception("isExam = false nhưng thiếu thời gian học");
    }

    return ScheduleItemModel(
      idUnitOfStudy: json['idUnitOfStudy'],
      subjectName: json['subjectName'],
      room: json['room'],
      startStudyTime: startStudyTime,
      endStudyTime: endStudyTime,
      examTime: examTime,
      isExam: isExam,
      noExamShift: json['noExamShift'],
      noExamGroup: json['noExamGroup'],
    );
  }
}
