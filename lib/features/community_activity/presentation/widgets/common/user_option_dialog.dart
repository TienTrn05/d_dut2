import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/utils/getit_utils.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart' as dialog;
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/community_activity/bloc/community_activity/community_activity_bloc.dart';
import 'package:e_dut/features/community_activity/constant/user_activity_status.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/domain/repository/community_repo.dart';
import 'package:e_dut/features/community_activity/presentation/screens/detail_user_activity_screen.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/cards/user_activity_card.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/submit_proof_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class UserOptionDialog extends StatefulWidget {
  const UserOptionDialog(
      {super.key,
      required this.userActivity,
      required this.keyword,
      required this.academicYearId,
      required this.status,
      required this.pageNumber,
      required this.communityBloc,
      this.onRefresh});

  final CommunityActivityBloc communityBloc;
  final String keyword;
  final String academicYearId;
  final String? status;
  final int pageNumber;
  final UserActivityModel userActivity;
  final VoidCallback? onRefresh;

  @override
  State<UserOptionDialog> createState() => _UserOptionDialogState();
}

class _UserOptionDialogState extends State<UserOptionDialog> {
  XFile? pickedImage;
  bool isImageValid = true;
  final descriptionController = TextEditingController();
  final picker = ImagePicker();

  void _showProofSubmission() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthUserAuthenticated) {
      final token = authState.accessToken;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return SubmitProofModal(
            token: token,
            keyword: widget.keyword,
            academicYearId: widget.academicYearId,
            status: widget.status,
            bloc: widget.communityBloc,
            userActivity: widget.userActivity,
          );
        },
      );
    }
  }

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
          widget.communityBloc.add(CancelRegistration(
            token: token,
            keyword: widget.keyword,
            academicYearId: widget.academicYearId,
            idActivity: widget.userActivity.activity.id,
            status: widget.status,
            pageNumber: widget.pageNumber,
          ));
          Navigator.pop(context);
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
          widget.communityBloc.add(ReRegistActivity(
              token: token,
              keyword: widget.keyword,
              academicYearId: widget.academicYearId,
              idActivity: widget.userActivity.activity.id,
              status: widget.status,
              pageNumber: widget.pageNumber));
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.userActivity.status;
    final startDate = widget.userActivity.activity.startDate;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserActivityCard(
            userActivity: widget.userActivity,
            keyword: widget.keyword,
            academicYearId: widget.academicYearId,
            pageNumber: widget.pageNumber,
            status: widget.status,
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
                  children: [
                    _buildDialogAction(
                      label: "Xem chi tiết",
                      icon: "assets/icons/svg/heroicons_viewfinder-circle.svg",
                      color: context.theme.grey!,
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                      create: (_) => CommunityActivityBloc(
                                          getIt.get<CommunityRepository>()),
                                      child: DetailUserActivityScreen(
                                          userActivity: widget.userActivity,
                                          communityBloc: widget.communityBloc),
                                    )));
                        if (result == true) {
                          widget.onRefresh?.call();
                        }
                      },
                    ),
                    if (status == UserActivityStatus.registered) ...[
                      _buildDialogAction(
                        label: "Hủy đăng ký",
                        icon:
                            "assets/icons/svg/material-symbols_cancel-outline-rounded.svg",
                        color: const Color(0xFFF97316),
                        onTap: _cancelRegistration,
                      ),
                      _buildDialogAction(
                          label: "Nộp minh chứng",
                          icon: "assets/icons/svg/lucide_file-check-2.svg",
                          color: const Color(0xFF47B5C1),
                          onTap: _showProofSubmission,
                          isEnabled: (startDate.isAfter(DateTime.now())
                              ? false
                              : true)),
                    ],
                    if (status == UserActivityStatus.canceled)
                      _buildDialogAction(
                        label: "Đăng ký",
                        icon:
                            "assets/icons/svg/material-symbols_app-registration-rounded.svg",
                        color: const Color(0xFF7CB305),
                        onTap: _reRegisterActivity,
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

  Widget _buildDialogAction({
    required String label,
    required String icon,
    required Color color,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    final actionContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: color, fontSize: FontSizes.small)),
          SvgPicture.asset(
            icon,
            height: 18,
            width: 18,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          )
        ],
      ),
    );
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.4,
        child: actionContent,
      ),
    );
  }
}
