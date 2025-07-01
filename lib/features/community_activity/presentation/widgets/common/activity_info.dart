import 'package:e_dut/features/community_activity/constant/activity_icon_path.dart';
import 'package:e_dut/features/community_activity/data/model/activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/items/activity_detail_item.dart';
import 'package:e_dut/features/community_activity/util/functions.dart';
import 'package:flutter/material.dart';

class ActivityInfo extends StatelessWidget {
  final ActivityModel activity;
  const ActivityInfo({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ActivityDetailItem(
          title: "Ngày diễn ra",
          content:
              "Bắt đầu: ${Functions.formatDate(activity.startDate)} \nKết thúc: ${Functions.formatDate(activity.endDate)}",
          iconPath: ActivityIconPath.calendar,
        ),
        const SizedBox(height: 10),
        ActivityDetailItem(
          title: "Ngày đăng ký",
          content:
              "Bắt đầu: ${Functions.formatDate(activity.startRegistration)} \nKết thúc: ${Functions.formatDate(activity.endRegistration)}",
          iconPath: ActivityIconPath.registration,
        ),
        const SizedBox(height: 10),
        ActivityDetailItem(
          title: "Địa điểm",
          content: activity.address,
          iconPath: ActivityIconPath.location,
        ),
        const SizedBox(height: 10),
        ActivityDetailItem(
          title: "Người tham gia",
          content:
              "Tối đa: ${activity.maxParticipants} \nĐã đăng ký: ${activity.participants}",
          iconPath: ActivityIconPath.participants,
        ),
        const SizedBox(height: 10),
        ActivityDetailItem(
          title: "Điểm số",
          content: activity.score.toString(),
          iconPath: ActivityIconPath.score,
        ),
        const SizedBox(height: 10),
        ActivityDetailItem(
          title: "Bên ngoài",
          content: activity.isExternal ? "Có" : "Không",
          iconPath: ActivityIconPath.external,
        ),
      ],
    );
  }
}
