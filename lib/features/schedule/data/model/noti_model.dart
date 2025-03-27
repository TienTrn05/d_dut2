class NotiModel {
  final DateTime createdDate;
  final String title;
  final String content;

  NotiModel(
      {required this.createdDate, required this.title, required this.content});

  factory NotiModel.fromJson(Map<String, dynamic> json) {
    return NotiModel(
      createdDate: json['createdDate'],
      title: json['title'],
      content: json['content'],
    );
  }
  static List<NotiModel> mockData = [
    NotiModel(
      createdDate: DateTime(2025, 2, 10),
      title: "CHÚ Ý: Thông báo đổi phòng học",
      content: "Đổi sang phòng E205",
    ),
    NotiModel(
      createdDate: DateTime(2024, 12, 11),
      title: "NGHỈ HỌC 21/02/2025",
      content: "Lớp nghỉ học vì thầy bận học hội nghị",
    ),
  ];
}
