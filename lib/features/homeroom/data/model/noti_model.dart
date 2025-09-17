class NotiModel {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final bool isRead;

  NotiModel(
      {required this.id,
      required this.date,
      required this.title,
      required this.content,
      this.isRead = false});

  factory NotiModel.fromJson(Map<String, dynamic> json) {
    return NotiModel(
      id: json['createdDate'],
      date: json['createdDate'],
      title: json['title'],
      content: json['content'],
      isRead: json['isRead'] ?? false,
    );
  }
}
