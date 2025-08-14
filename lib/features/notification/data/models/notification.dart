class Notification {
  final String id;
  final String title;
  final String body;
  final bool read;
  final String? link;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    this.link,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    // Get the timestamp map from the JSON
    final Map<String, dynamic> timestampJson = json['createdAt'];
    // Extract the seconds part
    final int seconds = timestampJson['_seconds'];
    // Convert seconds since epoch to a DateTime object
    final DateTime createdAtDate = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

    return Notification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      read: json['read'],
      link: json['link'],
      createdAt: createdAtDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'read': read,
      'link': link,
    };
  }
}