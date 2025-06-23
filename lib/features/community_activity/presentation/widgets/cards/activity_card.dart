import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart' as dialog;
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/community_activity/bloc/all_activities/all_activities_bloc.dart';
import 'package:e_dut/features/community_activity/constant/activity_icon_path.dart';
import 'package:e_dut/features/community_activity/constant/activity_status.dart';
import 'package:e_dut/features/community_activity/data/model/activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/status_label.dart';
import 'package:e_dut/features/community_activity/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final String authToken;
  final String keyword;

  const ActivityCard(
      {super.key,
      required this.activity,
      required this.authToken,
      required this.keyword});

  @override
  Widget build(BuildContext context) {
    void registActivity() {
      dialog.CustomAlertDialog.showCustomDialog(
          context,
          "Xác nhận đăng ký",
          "Bạn có chắc chắn đăng ký tham gia hoạt động \"${activity.name}\"?",
          textConfirm: "Đăng ký",
          dialog.AlertType.confirm, onConfirm: () {
        context.read<AllActivitiesBloc>().add(RegistActivity(
            token: authToken, keyword: keyword, idActivity: activity.id));
      });
    }

    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      // final String userRole = authState is AuthUserAuthenticated
      //     ? authState.userData.role.name
      //     : '';
      return GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(Routes.detailCommunityActivity, arguments: activity);
        },
        child: Container(
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
                      statusCode: activity.status,
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
                                ActivityIconPath.score,
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
                          fontSize: FontSizes.small,
                          fontStyle: FontStyle.italic),
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
                          ActivityIconPath.participants,
                          colorFilter: ColorFilter.mode(
                              context.theme.grey ?? Colors.grey,
                              BlendMode.srcIn),
                          width: 13,
                          height: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${activity.participants.toString()}/${activity.maxParticipants.toString()}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: FontSizes.small,
                              color: context.theme.grey),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          ActivityIconPath.calendar,
                          colorFilter: ColorFilter.mode(
                              context.theme.grey ?? Colors.grey,
                              BlendMode.srcIn),
                          width: 13,
                          height: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${Functions.formatDate(activity.startDate)} - ${Functions.formatDate(activity.endDate)}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: FontSizes.small,
                              color: context.theme.grey),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          ActivityIconPath.location,
                          colorFilter: ColorFilter.mode(
                              context.theme.grey ?? Colors.grey,
                              BlendMode.srcIn),
                          width: 13,
                          height: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity.address,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: FontSizes.small,
                              color: context.theme.grey),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    if (activity.status == ActivityStatus.registrationOpen)
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
                          onPressed: registActivity,
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
        ),
      );
    });
  }
}
