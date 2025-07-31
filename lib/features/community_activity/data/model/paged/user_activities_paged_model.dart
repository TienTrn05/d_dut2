import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';

class UserActivitiesPagedModel {
  final List<UserActivityModel> activities;
  final int total;
  final String page;
  final String limit;

  UserActivitiesPagedModel(
      {required this.activities,
      required this.total,
      required this.page,
      required this.limit});

  factory UserActivitiesPagedModel.fromJson(Map<String, dynamic> json) {
    return UserActivitiesPagedModel(
        activities: json['activities'] != null
            ? (json['activities'] as List)
                .map((activity) => UserActivityModel.fromJson(activity))
                .toList()
            : [],
        total: (json['total'] as int?) ?? 0,
        page: json['page'] ?? '',
        limit: json['limit'] ?? '');
  }
}
