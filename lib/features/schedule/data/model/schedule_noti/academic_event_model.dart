class AcademicEventModel {
  final String idAcademicEvent;
  final String idUnitOfStudy;
  final DateTime eventDate;
  final int eventType;
  final String room;
  final int noWeek;
  final String subjectName;

  AcademicEventModel({
    required this.idAcademicEvent,
    required this.idUnitOfStudy,
    required this.eventDate,
    required this.eventType,
    required this.room,
    required this.noWeek,
    required this.subjectName,
  });

  factory AcademicEventModel.fromJson(Map<String, dynamic> json) {
    return AcademicEventModel(
      idAcademicEvent: json['idAcademicEvent'] ?? '',
      idUnitOfStudy: json['idUnitOfStudy'] ?? '',
      eventDate: DateTime.parse(json['eventDate']),
      eventType: (json['eventType'] as num?)?.toInt() ?? 0,
      room: json['room'] ?? '',
      noWeek: (json['noWeek'] as num?)?.toInt() ?? 0,
      subjectName: json['subjectName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAcademicEvent': idAcademicEvent,
      'idUnitOfStudy': idUnitOfStudy,
      'eventDate': eventDate.toIso8601String(),
      'eventType': eventType,
      'room': room,
      'noWeek': noWeek,
      'subjectName': subjectName,
    };
  }
}
