import 'package:e_dut/features/community_activity/data/model/user_info_model.dart';

class CommentModel {
  final String id;
  final String content;
  final DateTime createdAt;
  final UserInfoModel user;

  CommentModel(
      {required this.id,
      required this.content,
      required this.createdAt,
      required this.user});

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
        id: json['id'],
        content: json['content'],
        createdAt: DateTime.parse(json['createdAt']),
        user: UserInfoModel.fromJson(json['user']));
  }
}
