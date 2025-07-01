import 'package:e_dut/features/community_activity/data/model/activity_model.dart';

class UserActivityModel {
  final String id;
  final String status;
  final ActivityModel activity;

  UserActivityModel(
      {required this.id, required this.status, required this.activity});

  factory UserActivityModel.fromJson(Map<String, dynamic> json) {
    return UserActivityModel(
        id: json['id'],
        status: json['status'],
        activity: ActivityModel.fromJson(json['activity']));
  }
}
