import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart' as dialog;
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/community_activity/bloc/community_activity/community_activity_bloc.dart';
import 'package:e_dut/features/community_activity/constant/activity_status.dart';
import 'package:e_dut/features/community_activity/data/model/activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/activity_info.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/status_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailActivityScreen extends StatefulWidget {
  final ActivityModel activity;

  final CommunityActivityBloc communityBloc;

  const DetailActivityScreen(
      {super.key, required this.activity, required this.communityBloc});

  @override
  State<DetailActivityScreen> createState() => _DetailActivityScreenState();
}

class _DetailActivityScreenState extends State<DetailActivityScreen> {
  void _registActivity() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthUserAuthenticated) {
      final token = authState.accessToken;
      dialog.CustomAlertDialog.showCustomDialog(
        context,
        "Xác nhận đăng ký",
        "Bạn có chắc chắn đăng ký tham gia hoạt động \"${widget.activity.name}\"?",
        textCancel: "Đóng",
        dialog.AlertType.confirm,
        onConfirm: () {
          widget.communityBloc.add(RegistActivity(
            token: token,
            keyword: '',
            idActivity: widget.activity.id,
          ));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityActivityBloc, CommunityActivityState>(
        bloc: widget.communityBloc,
        builder: (context, state) {
          if (state is CommunityActivityLoading) {
            return CustomLoadingIndicator.primary();
          } else if (state is AllActivitiesLoaded) {
            final activity = state.activities.firstWhere(
              (a) => a.id == widget.activity.id,
            );
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: CustomAppbar(label: "Chi tiết hoạt động"),
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 3 / 2,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Ảnh nền
                            (activity.image != null)
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

                            // Lớp phủ gradient
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withAlpha(56),
                                    Colors.black.withAlpha(180)
                                  ],
                                ),
                              ),
                            ),

                            // Nội dung sát đáy, scroll nếu vượt
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activity.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: FontSizes.medium,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          StatusLabel(
                                            statusType: StatusType.activity,
                                            statusCode: activity.status ?? '',
                                            isFullWidth: false,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            activity.createdBy,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: FontSizes.small,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            activity.subcategory.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: FontSizes.small,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                        child: SingleChildScrollView(
                      child: ActivityInfo(
                        activity: activity,
                      ),
                    )),
                    if (activity.status == ActivityStatus.registrationOpen)
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: context.theme.primaryColor,
                                    textStyle: const TextStyle(
                                      inherit: false,
                                      fontWeight: FontWeight.bold,
                                      fontSize: FontSizes.medium,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    )),
                                onPressed: _registActivity,
                                child: const Text('Đăng ký')),
                          )
                        ],
                      )
                  ],
                ),
              ),
            );
          } else {
            return CustomLoadingIndicator.primary();
          }
        });
  }
}
