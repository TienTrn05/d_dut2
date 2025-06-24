import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/features/community_activity/constant/activity_icon_path.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/status_label.dart';
import 'package:e_dut/features/community_activity/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserActivityCard extends StatelessWidget {
  final UserActivityModel userActivity;

  const UserActivityCard({super.key, required this.userActivity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.detailCommunityActivity, arguments: userActivity);
      },
      onLongPress: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(64),
              blurRadius: 8,
              offset: Offset(2, 4))
        ], color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      userActivity.activity.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: FontSizes.medium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        ActivityIconPath.score,
                        colorFilter: ColorFilter.mode(
                            Color(0XFFFFFF01), BlendMode.srcIn),
                        width: 13,
                        height: 13,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        userActivity.activity.score.toString(),
                        style: TextStyle(fontSize: FontSizes.medium),
                      ),
                    ],
                  ),
                ]),
            const SizedBox(height: 4),
            Text(
              '${Functions.formatDate(userActivity.activity.startDate)} - ${Functions.formatDate(userActivity.activity.endDate)}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: FontSizes.small, color: context.theme.grey),
            ),
            const SizedBox(height: 4),
            StatusLabel(
              statusType: StatusType.userActivity,
              statusCode: userActivity.status,
              isFullWidth: false,
            )
          ],
        ),
      ),
    );
  }
}
