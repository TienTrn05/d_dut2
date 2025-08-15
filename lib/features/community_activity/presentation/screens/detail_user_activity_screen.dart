import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart' as dialog;
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart';
import 'package:e_dut/common/widgets/snackbar/custom_snackbar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/community_activity/bloc/community_activity/community_activity_bloc.dart';
import 'package:e_dut/features/community_activity/constant/user_activity_status.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/activity_info.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/status_label.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/submit_proof_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailUserActivityScreen extends StatefulWidget {
  final UserActivityModel userActivity;

  final CommunityActivityBloc communityBloc;

  const DetailUserActivityScreen(
      {super.key, required this.userActivity, required this.communityBloc});

  @override
  State<DetailUserActivityScreen> createState() =>
      _DetailUserActivityScreenState();
}

class _DetailUserActivityScreenState extends State<DetailUserActivityScreen> {
  late UserActivityModel _currentUserActivity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUserActivity = widget.userActivity;
  }

  bool get isEnabledSubmitProof =>
      _currentUserActivity.activity.startDate.isBefore(DateTime.now());

  void _cancelRegistration() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthUserAuthenticated) return;

    dialog.CustomAlertDialog.showCustomDialog(
      context,
      "Hủy đăng ký",
      "Bạn có chắc chắn muốn hủy đăng ký hoạt động \"${_currentUserActivity.activity.name}\"?",
      textCancel: "Đóng",
      dialog.AlertDialogType.delete,
      onConfirm: () {
        widget.communityBloc.add(CancelRegistration(
          token: authState.accessToken,
          keyword: '',
          academicYearId: widget.userActivity.activity.academicYearActivity!.id,
          status: null,
          idActivity: widget.userActivity.activity.id,
          pageNumber: 1,
        ));
      },
    );
  }

  void _reRegisterActivity() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthUserAuthenticated) return;

    dialog.CustomAlertDialog.showCustomDialog(
      context,
      "Xác nhận đăng ký",
      "Bạn có chắc chắn đăng ký tham gia hoạt động \"${_currentUserActivity.activity.name}\"?",
      textCancel: "Đóng",
      dialog.AlertDialogType.confirm,
      onConfirm: () {
        widget.communityBloc.add(ReRegistActivity(
          token: authState.accessToken,
          keyword: '',
          academicYearId: widget.userActivity.activity.academicYearActivity!.id,
          status: null,
          idActivity: widget.userActivity.activity.id,
          pageNumber: 1,
        ));
      },
    );
  }

  void _showProofSubmission() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthUserAuthenticated) return;

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
          value: widget.communityBloc,
          child: SubmitProofModal(
            token: authState.accessToken,
            keyword: '',
            academicYearId:
                widget.userActivity.activity.academicYearActivity!.id,
            status: null,
            bloc: widget.communityBloc,
            userActivity: widget.userActivity,
            fromCard: false,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommunityActivityBloc, CommunityActivityState>(
      bloc: widget.communityBloc,
      listener: (context, state) {
        if (state is UserActivitiesLoaded) {
          final UserActivityModel updatedActivity =
              state.pagedActivities.activities.firstWhere(
            (a) => a.id == _currentUserActivity.id,
            orElse: () => _currentUserActivity,
          );
          setState(() {
            _currentUserActivity = updatedActivity;
            _isLoading = false;
          });
        } else if (state is CommunityActivityLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is CommunityActivityError) {
          setState(() {
            _isLoading = false;
          });
          CustomSnackbar.showSnackBar(
            context,
            "Thất bại",
            state.message,
            AlertType.error,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppbar(label: "Chi tiết hoạt động"),
          body: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Header với ảnh và thông tin cơ bản
                    _buildHeaderSection(),

                    const SizedBox(height: 10),

                    // Thông tin chi tiết hoạt động
                    Expanded(
                      child: SingleChildScrollView(
                        child: ActivityInfo(
                            activity: _currentUserActivity.activity),
                      ),
                    ),

                    // Action buttons
                    _buildActionButtons(),
                  ],
                ),
              ),

              // Loading overlay
              if (_isLoading) CustomLoadingIndicator.primary(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            (_currentUserActivity.activity.image != null)
                ? Image.network(
                    _currentUserActivity.activity.image!,
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

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(56),
                    Colors.black.withAlpha(180),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _currentUserActivity.activity.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: FontSizes.medium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatusLabel(
                    statusType: StatusType.userActivity,
                    statusCode: _currentUserActivity.status,
                    isFullWidth: false,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentUserActivity.activity.createdBy,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: FontSizes.small,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentUserActivity.activity.subcategory.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: FontSizes.small,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_currentUserActivity.status == UserActivityStatus.registered) {
      return Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              // Cancel button
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
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side:
                          const BorderSide(color: Color(0xFFF97316), width: 2),
                    ),
                  ),
                  onPressed: _isLoading ? null : _cancelRegistration,
                  child: const Text('Hủy đăng ký'),
                ),
              ),

              const SizedBox(width: 10),

              // Submit proof button
              Expanded(
                child: TextButton(
                  onPressed: (_isLoading || !isEnabledSubmitProof)
                      ? null
                      : _showProofSubmission,
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.grey.shade300;
                      }
                      return const Color(0xFF47B5C1);
                    }),
                    textStyle: WidgetStateProperty.all(
                      const TextStyle(
                        inherit: false,
                        fontWeight: FontWeight.bold,
                        fontSize: FontSizes.medium,
                      ),
                    ),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    shape: WidgetStateProperty.resolveWith((states) {
                      final isDisabled = states.contains(WidgetState.disabled);
                      return RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isDisabled
                              ? Colors.grey.shade300
                              : const Color(0xFF47B5C1),
                          width: 2,
                        ),
                      );
                    }),
                  ),
                  child: const Text('Nộp minh chứng'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_currentUserActivity.status == UserActivityStatus.canceled) {
      return Column(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isLoading ? null : _reRegisterActivity,
              child: const Text('Đăng ký'),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
