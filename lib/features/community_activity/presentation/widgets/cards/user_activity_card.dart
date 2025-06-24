import 'dart:ui';

import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart' as dialog;
import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/community_activity/bloc/community_activity/community_activity_bloc.dart';
import 'package:e_dut/features/community_activity/constant/activity_icon_path.dart';
import 'package:e_dut/features/community_activity/constant/user_activity_status.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/status_label.dart';
import 'package:e_dut/features/community_activity/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class UserActivityCard extends StatefulWidget {
  final UserActivityModel userActivity;
  final String keyword;

  const UserActivityCard(
      {super.key, required this.userActivity, required this.keyword});

  @override
  State<UserActivityCard> createState() => _UserActivityCardState();
}

class _UserActivityCardState extends State<UserActivityCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _colorController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller cho scale effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Animation controller cho color effect
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Scale animation (phóng to nhẹ)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

    // Color animation (đổi màu nhẹ)
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.grey.shade100,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _handleLongPressStart() async {
    // Bắt đầu animation
    _scaleController.forward();
    _colorController.forward();

    // Chờ animation hoàn thành
    await Future.delayed(const Duration(milliseconds: 150));

    // Scale về bình thường
    _scaleController.reverse();
    _colorController.reverse();

    // Chờ một chút để animation reverse hoàn thành
    await Future.delayed(const Duration(milliseconds: 200));

    // Hiển thị dialog
    if (mounted) {
      _showOptionsDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _colorAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.detailUserActivityScreen,
                arguments: widget.userActivity,
              );
            },
            onLongPress: _handleLongPressStart,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(64),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  )
                ],
                color: _colorAnimation.value ?? Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
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
                          widget.userActivity.activity.name,
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
                            widget.userActivity.activity.score.toString(),
                            style: TextStyle(fontSize: FontSizes.medium),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Functions.formatDate(widget.userActivity.activity.startDate)} - ${Functions.formatDate(widget.userActivity.activity.endDate)}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: FontSizes.small,
                      color: context.theme.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusLabel(
                    statusType: StatusType.userActivity,
                    statusCode: widget.userActivity.status,
                    isFullWidth: false,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showOptionsDialog(BuildContext context) {
    final communitybloc = context.read<CommunityActivityBloc>();
    final authBloc = context.read<AuthBloc>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: _DialogContent(
                userActivity: widget.userActivity,
                keyword: widget.keyword,
                communityBloc: communitybloc,
                authBloc: authBloc,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Animation cho dialog xuất hiện
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        ));

        final opacityAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ));

        return FadeTransition(
          opacity: opacityAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

class _DialogContent extends StatelessWidget {
  final UserActivityModel userActivity;
  final String keyword;
  final CommunityActivityBloc communityBloc;
  final AuthBloc authBloc;

  const _DialogContent(
      {required this.userActivity,
      required this.keyword,
      required this.communityBloc,
      required this.authBloc});

  @override
  Widget build(BuildContext context) {
    void cancelRegistration() {
      final authState = authBloc.state;
      if (authState is AuthUserAuthenticated) {
        final authToken = authState.accessToken;
        dialog.CustomAlertDialog.showCustomDialog(
            context,
            "Hủy đăng ký",
            "Bạn có chắc chắn muốn hủy đăng ký hoạt động \"${userActivity.activity.name}\"?",
            textCancel: "Đóng",
            dialog.AlertType.delete, onConfirm: () {
          communityBloc.add(CancelRegistration(
              token: authToken,
              keyword: keyword,
              idActivity: userActivity.activity.id));
          Navigator.pop(context);
        });
      }
    }

    void registActivity() {
      final authState = authBloc.state;
      if (authState is AuthUserAuthenticated) {
        final authToken = authState.accessToken;
        dialog.CustomAlertDialog.showCustomDialog(
            context,
            "Xác nhận đăng ký",
            "Bạn có chắc chắn đăng ký tham gia hoạt động \"${userActivity.activity.name}\"?",
            textCancel: "Đóng",
            dialog.AlertType.confirm, onConfirm: () {
          communityBloc.add(ReRegistActivity(
              token: authToken,
              keyword: keyword,
              idActivity: userActivity.activity.id));
          Navigator.pop(context);
        });
      }
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserActivityCard(
            userActivity: userActivity,
            keyword: keyword,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.65,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(
                          Routes.detailUserActivityScreen,
                          arguments: userActivity,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Xem chi tiết",
                              style: TextStyle(
                                color: context.theme.grey,
                                fontSize: FontSizes.small,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                            SvgPicture.asset(
                              "assets/icons/svg/heroicons_viewfinder-circle.svg",
                              height: 18,
                              width: 18,
                              colorFilter: ColorFilter.mode(
                                  context.theme.grey ?? Colors.grey,
                                  BlendMode.srcIn),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (userActivity.status == UserActivityStatus.registered)
                      GestureDetector(
                        onTap: () {
                          cancelRegistration();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Hủy đăng ký",
                                style: TextStyle(
                                  color: Color(0xFFF97316),
                                  fontSize: FontSizes.small,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              SvgPicture.asset(
                                "assets/icons/svg/material-symbols_cancel-outline-rounded.svg",
                                height: 18,
                                width: 18,
                                colorFilter: ColorFilter.mode(
                                    Color(0xFFF97316), BlendMode.srcIn),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (userActivity.status == UserActivityStatus.registered)
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Nộp minh chứng",
                                style: TextStyle(
                                  color: Color(0xFF47B5C1),
                                  fontSize: FontSizes.small,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              SvgPicture.asset(
                                "assets/icons/svg/lucide_file-check-2.svg",
                                height: 18,
                                width: 18,
                                colorFilter: ColorFilter.mode(
                                    Color(0xFF47B5C1), BlendMode.srcIn),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (userActivity.status == UserActivityStatus.canceled)
                      GestureDetector(
                        onTap: () {
                          registActivity();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Đăng ký",
                                style: TextStyle(
                                  color: Color(0xFF7CB305),
                                  fontSize: FontSizes.small,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              SvgPicture.asset(
                                "assets/icons/svg/material-symbols_app-registration-rounded.svg",
                                height: 18,
                                width: 18,
                                colorFilter: ColorFilter.mode(
                                    Color(0xFF7CB305), BlendMode.srcIn),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
