import 'package:e_dut/features/community_activity/data/model/activity_model.dart';

class ActivitiesPagedModel {
  final List<ActivityModel> activities;
  final int total;
  final String page;
  final String limit;

  ActivitiesPagedModel(
      {required this.activities,
      required this.total,
      required this.page,
      required this.limit});

  factory ActivitiesPagedModel.fromJson(Map<String, dynamic> json) {
    return ActivitiesPagedModel(
        activities: json['activities'] != null
            ? (json['activities'] as List)
                .map((activity) => ActivityModel.fromJson(activity))
                .toList()
            : [],
        total: (json['total'] as int?) ?? 0,
        page: json['page'] ?? '',
        limit: json['limit'] ?? '');
  }
}
