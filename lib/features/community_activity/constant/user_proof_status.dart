import 'package:e_dut/features/auth/data/model/activity_status_style.dart';
import 'package:e_dut/features/community_activity/constant/user_activity_status.dart';

class UserProofStatus {
  static const List<String> keys = [
    UserActivityStatus.submitted,
    UserActivityStatus.approved,
    UserActivityStatus.rejected,
  ];

  static final Map<String, ActivityStatusStyle> styles = Map.fromEntries(
    keys.map(
        (key) => MapEntry(key, UserActivityStatus.activityStatusStyles[key]!)),
  );
}
