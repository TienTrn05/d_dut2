import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart' as dialog;
import 'package:e_dut/common/widgets/snackbar/custom_snackbar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/community_activity/bloc/community_activity/community_activity_bloc.dart';
import 'package:e_dut/features/community_activity/constant/user_activity_status.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/activity_info.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/status_label.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/submit_proof_modal.dart';
import 'package:e_dut/features/dashboard/presentation/widgets/notification_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailUserActivityScreen extends StatefulWidget {
  final UserActivityModel userActivity;

  const DetailUserActivityScreen({super.key, required this.userActivity});

  @override
  State<DetailUserActivityScreen> createState() =>
      _DetailUserActivityScreenState();
}

class _DetailUserActivityScreenState extends State<DetailUserActivityScreen> {
  late UserActivityModel _userActivity;

  void _cancelRegistration() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthUserAuthenticated) {
      final token = authState.accessToken;
      dialog.CustomAlertDialog.showCustomDialog(
        context,
        "Hủy đăng ký",
        "Bạn có chắc chắn muốn hủy đăng ký hoạt động \"${widget.userActivity.activity.name}\"?",
        textCancel: "Đóng",
        dialog.AlertType.delete,
        onConfirm: () {
          context.read<CommunityActivityBloc>().add(CancelRegistration(
                token: token,
                keyword: '',
                idActivity: widget.userActivity.activity.id,
              ));
        },
      );
    }
  }

  void _reRegisterActivity() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthUserAuthenticated) {
      final token = authState.accessToken;
      dialog.CustomAlertDialog.showCustomDialog(
        context,
        "Xác nhận đăng ký",
        "Bạn có chắc chắn đăng ký tham gia hoạt động \"${widget.userActivity.activity.name}\"?",
        textCancel: "Đóng",
        dialog.AlertType.confirm,
        onConfirm: () {
          context.read<CommunityActivityBloc>().add(ReRegistActivity(
                token: token,
                keyword: '',
                idActivity: widget.userActivity.activity.id,
              ));
        },
      );
    }
  }

  void _showProofSubmission() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthUserAuthenticated) {
      final token = authState.accessToken;
      final communityBloc = context.read<CommunityActivityBloc>();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return BlocProvider.value(
              value: communityBloc,
              child: SubmitProofModal(
                token: token,
                keyword: '',
                bloc: communityBloc,
                userActivity: widget.userActivity,
                fromCard: false,
              ));
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _userActivity = widget.userActivity;
  }

  @override
  Widget build(BuildContext context) {
    final isEnabledSubmitProof =
        (_userActivity.activity.startDate.isAfter(DateTime.now()))
            ? false
            : true;
    return BlocListener<CommunityActivityBloc, CommunityActivityState>(
      listener: (context, state) {
        if (state is UserActivitiesLoaded) {
          setState(() {
            final updatedActivity = state.activities.firstWhere(
              (a) => a.id == widget.userActivity.id,
              orElse: () => widget.userActivity,
            );
            _userActivity = updatedActivity;
          });
        }
        if (state is CommunityActivityError) {
          CustomSnackbar.showSnackBar(
              context, "Thất bại", state.message, AlertType.error);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: context.theme.primaryColor ?? Colors.blue,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context, true),
            ),
          ),
          title: Text(
            'Chi tiết hoạt động',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: FontSizes.medium,
            ),
          ),
          centerTitle: true,
          actions: [
            NotificationButton(
              notificationCount: 2,
              onTap: () =>
                  {Navigator.of(context).pushNamed(Routes.notification)},
            ),
          ],
        ),
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
                      (_userActivity.activity.image != null)
                          ? Image.network(
                              _userActivity.activity.image!,
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

                      // Lớp Linear Gradient
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
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              _userActivity.activity.name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: FontSizes.medium,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            StatusLabel(
                              statusType: StatusType.userActivity,
                              statusCode: _userActivity.status,
                              isFullWidth: false,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _userActivity.activity.createdBy,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: FontSizes.small,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _userActivity.activity.subcategory.name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: FontSizes.small,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                  child: SingleChildScrollView(
                child: ActivityInfo(activity: _userActivity.activity),
              )),
              if (_userActivity.status == UserActivityStatus.registered)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            child: TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFF97316),
                                    textStyle: const TextStyle(
                                      inherit: false,
                                      fontWeight: FontWeight.bold,
                                      fontSize: FontSizes.medium,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(
                                            color: Color(0xFFF97316),
                                            width: 2))),
                                onPressed: _cancelRegistration,
                                child: const Text('Hủy đăng ký'))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: TextButton(
                          onPressed: isEnabledSubmitProof
                              ? _showProofSubmission
                              : null,
                          style: ButtonStyle(
                            foregroundColor:
                                WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.disabled)) {
                                return Colors.grey.shade300;
                              }
                              return Color(0xFF47B5C1);
                            }),
                            textStyle: WidgetStateProperty.all(
                              const TextStyle(
                                inherit: false,
                                fontWeight: FontWeight.bold,
                                fontSize: FontSizes.medium,
                              ),
                            ),
                            padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16)),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: isEnabledSubmitProof
                                          ? Color(0xFF47B5C1)
                                          : Colors.grey.shade300,
                                      width: 2)),
                            ),
                          ),
                          child: const Text('Nộp minh chứng'),
                        ))
                      ],
                    )
                  ],
                ),
              if (_userActivity.status == UserActivityStatus.canceled)
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
                            ),
                          ),
                          onPressed: _reRegisterActivity,
                          child: const Text('Đăng ký')),
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
