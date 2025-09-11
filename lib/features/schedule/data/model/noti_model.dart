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
  static List<NotiModel> mockData = [
    NotiModel(
        id: "1",
        date: DateTime(2025, 02, 14),
        title: "CHÚ Ý: Thông báo đổi phòng học",
        content: "Đổi sang phòng E205",
        isRead: true),
    NotiModel(
      id: "2",
      date: DateTime(2025, 02, 10),
      title: "NGHỈ HỌC 21/02/2025",
      content: "Lớp nghỉ học vì thầy bận học hội nghị",
    ),
    NotiModel(
      id: "3",
      date: DateTime(2024, 12, 11),
      title: "V/v Nộp bài tập NLB",
      content:
          "Chào các em, \nDo chiều mai sau khi thi xong Thầy bận họp về Bảo vệ Đồ án Tốt nghiệp nên các em sẽ nộp bài tập NLB vào 1h - 2h30 chiều mai tại C204 đồng thời ký bảng điểm Giữa kỳ luôn.",
    ),
    NotiModel(
        id: "4",
        date: DateTime(2024, 12, 10),
        title: "[Thống kê] Điểm bài tập",
        content:
            "1. Cho các em tạm ứng bài NLB, sau khi thi cuối kỳ sẽ nộp. Ai không nộp thì trừ lại \n2. Thống kê theo link trong Teams Files. Thắc mắc gì inbox Thầy.",
        isRead: true),
  ];
}
