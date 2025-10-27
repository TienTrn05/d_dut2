import 'package:equatable/equatable.dart';

class WeeklyScheduleItem extends Equatable {
  final DateTime day;
  final DateTime start;
  final DateTime end;
  final String content;
  final String participants;
  final String location;
  final String host;

  const WeeklyScheduleItem({
    required this.day,
    required this.start,
    required this.end,
    required this.content,
    required this.participants,
    required this.location,
    required this.host,
  });

  factory WeeklyScheduleItem.fromJson(Map<String, dynamic> json) {
    final dayStr = (json['day'] ?? '').toString();
    final startStr = (json['start'] ?? '00:00:00').toString();
    final endStr = (json['end'] ?? '00:00:00').toString();

    final day = DateTime.parse(dayStr); // yyyy-MM-dd
    final start = DateTime.parse('${dayStr}T$startStr');
    final end = DateTime.parse('${dayStr}T$endStr');

    return WeeklyScheduleItem(
      day: day,
      start: start,
      end: end,
      content: _decodeHtml((json['content'] ?? '').toString()),
      participants: _decodeHtml((json['participants'] ?? '').toString()),
      location: (json['location'] ?? '').toString(),
      host: (json['host_display_name'] ?? '').toString(),
    );
  }

  static String _decodeHtml(String s) {
    // API có entity &amp; và escape \u003C \u003E
    return s
        .replaceAll(r'\u003C', '<')
        .replaceAll(r'\u003E', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  @override
  List<Object?> get props => [
    day,
    start,
    end,
    content,
    participants,
    location,
    host,
  ];
}

class WeeklyScheduleResponse {
  final String status;
  final String name;
  final String email;
  final List<WeeklyScheduleItem> schedules;

  WeeklyScheduleResponse({
    required this.status,
    required this.name,
    required this.email,
    required this.schedules,
  });

  factory WeeklyScheduleResponse.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map?) ?? const {};
    final items =
        (json['schedules'] as List? ?? const [])
            .whereType<Map>()
            .map(
              (e) => WeeklyScheduleItem.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();

    return WeeklyScheduleResponse(
      status: (json['status'] ?? '').toString(),
      name: (user['name'] ?? '').toString(),
      email: (user['email'] ?? '').toString(),
      schedules: items,
    );
  }
}
