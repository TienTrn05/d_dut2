import 'dart:ui';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/utils/getit_utils.dart';
import 'package:e_dut/features/community_activity/bloc/community_activity/community_activity_bloc.dart';
import 'package:e_dut/features/community_activity/constant/activity_icon_path.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/domain/repository/community_repo.dart';
import 'package:e_dut/features/community_activity/presentation/screens/detail_user_activity_screen.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/user_option_dialog.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/status_label.dart';
import 'package:e_dut/features/community_activity/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class UserActivityCard extends StatefulWidget {
  const UserActivityCard(
      {super.key,
      required this.keyword,
      required this.academicYearId,
      required this.status,
      required this.pageNumber,
      required this.userActivity,
      this.onRefresh});

  final String keyword;
  final String academicYearId;
  final String? status;
  final int pageNumber;
  final UserActivityModel userActivity;
  final VoidCallback? onRefresh;

  @override
  State<UserActivityCard> createState() => _UserActivityCardState();
}

class _UserActivityCardState extends State<UserActivityCard>
    with TickerProviderStateMixin {
  late Animation<Color?> _colorAnimation;
  late AnimationController _colorController;
  late Animation<double> _scaleAnimation;
  late AnimationController _scaleController;

  @override
  void dispose() {
    _scaleController.dispose();
    _colorController.dispose();
    super.dispose();
  }

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

  void _showOptionsDialog(BuildContext context) {
    final communitybloc = context.read<CommunityActivityBloc>();
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
              child: UserOptionDialog(
                userActivity: widget.userActivity,
                keyword: widget.keyword,
                academicYearId: widget.academicYearId,
                communityBloc: communitybloc,
                pageNumber: widget.pageNumber,
                status: widget.status,
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _colorAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () async {
              final communityBloc = context.read<CommunityActivityBloc>();
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BlocProvider(
                            create: (_) => CommunityActivityBloc(
                                getIt.get<CommunityRepository>()),
                            child: DetailUserActivityScreen(
                              userActivity: widget.userActivity,
                              communityBloc: communityBloc,
                              pageOfActivity: widget.pageNumber,
                            ),
                          )));
              if (result == true) {
                widget.onRefresh?.call();
              }
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
}
