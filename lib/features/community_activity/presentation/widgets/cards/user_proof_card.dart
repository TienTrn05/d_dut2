import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/community_activity/constant/activity_icon_path.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/status_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserProofCard extends StatelessWidget {
  final String nameActivity;
  final int score;
  final String? status;
  final VoidCallback? onPressed;

  const UserProofCard(
      {super.key,
      required this.nameActivity,
      required this.score,
      this.status,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
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
                    nameActivity,
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
                      colorFilter: const ColorFilter.mode(
                        Color(0XFFFFFF01),
                        BlendMode.srcIn,
                      ),
                      width: 13,
                      height: 13,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      score.toString(),
                      style: TextStyle(fontSize: FontSizes.medium),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (status != null)
              StatusLabel(
                statusType: StatusType.userActivity,
                statusCode: status!,
                isFullWidth: false,
              )
          ],
        ),
      ),
    );
  }
}
