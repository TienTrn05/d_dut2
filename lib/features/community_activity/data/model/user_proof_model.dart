import 'package:e_dut/features/community_activity/data/model/comment_model.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';

class UserProofModel {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final UserActivityModel userActivity;
  final List<CommentModel>? comments;

  UserProofModel(
      {required this.id,
      required this.name,
      required this.description,
      required this.image,
      required this.userActivity,
      required this.comments});

  factory UserProofModel.fromJson(Map<String, dynamic> json) {
    return UserProofModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      userActivity: UserActivityModel.fromJson(json['userActivity']),
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((comment) => CommentModel.fromJson(comment))
              .toList()
          : [],
    );
  }
}
