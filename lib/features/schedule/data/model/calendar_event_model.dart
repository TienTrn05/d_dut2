class EventTypeModel {
  // 1: Study, 2: Exam, Teaching: 3
  final int eventType;
  final String eventTypeDes;

  EventTypeModel({required this.eventType, required this.eventTypeDes});

  // Map dữ liệu từ API
  factory EventTypeModel.fromJson(Map<String, dynamic> json) {
    return EventTypeModel(
      eventType: json['eventType'],
      eventTypeDes: json['eventTypeDes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'eventTypeDes': eventTypeDes,
    };
  }
}

class CalendarEventModel {
  final DateTime date;
  final List<EventTypeModel> eventTypes;

  CalendarEventModel({
    required this.date,
    required this.eventTypes,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      date: DateTime.parse(json['date']),
      eventTypes: (json['eventTypes'] as List<
              dynamic>) // Chuyển mảng objectJSON về list các EventTypeModel
          .map((e) => EventTypeModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'eventTypes': eventTypes.map((e) => e.toJson()).toList(),
    };
  }
}
