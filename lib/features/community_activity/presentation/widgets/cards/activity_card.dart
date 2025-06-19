import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/community_activity/data/model/activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/status_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {
  final ActivityModel activity;

  const ActivityCard({super.key, required this.activity});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(64),
            blurRadius: 8,
            offset: Offset(2, 4))
      ], color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 74,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: (activity.image != null)
                        ? Image.network(
                            activity.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/default_image.jpg',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/default_image.jpg',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                StatusLabel(
                  statusCode: activity.status, //temp
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          activity.name,
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
                            "assets/icons/svg/mingcute_star-fill.svg",
                            colorFilter: ColorFilter.mode(
                                Color(0XFFFFFF01), BlendMode.srcIn),
                            width: 13,
                            height: 13,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            activity.score.toString(),
                            style: TextStyle(fontSize: FontSizes.medium),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  activity.organization,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: FontSizes.small, fontStyle: FontStyle.italic),
                ),
                const SizedBox(width: 4),
                Text(
                  activity.subcategory.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: FontSizes.small,
                      fontStyle: FontStyle.normal,
                      color: context.theme.grey),
                ),
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/svg/heroicons_user-group-solid.svg",
                      colorFilter: ColorFilter.mode(
                          context.theme.grey ?? Colors.grey, BlendMode.srcIn),
                      width: 13,
                      height: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${activity.participants.toString()}/${activity.maxParticipants.toString()}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: FontSizes.small, color: context.theme.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/svg/solar_calendar-bold.svg",
                      colorFilter: ColorFilter.mode(
                          context.theme.grey ?? Colors.grey, BlendMode.srcIn),
                      width: 13,
                      height: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(activity.startDate),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: FontSizes.small, color: context.theme.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/svg/weui_location-filled.svg",
                      colorFilter: ColorFilter.mode(
                          context.theme.grey ?? Colors.grey, BlendMode.srcIn),
                      width: 13,
                      height: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.address,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: FontSizes.small, color: context.theme.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: FontSizes.small),
                      backgroundColor: context.theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Đăng ký ngay",
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
