import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/utils/getit_utils.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart' as dialog;
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/community_activity/bloc/community_activity/community_activity_bloc.dart';
import 'package:e_dut/features/community_activity/constant/user_activity_status.dart';
import 'package:e_dut/features/community_activity/data/model/user_activity_model.dart';
import 'package:e_dut/features/community_activity/domain/repository/community_repo.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/activity_info.dart';
import 'package:e_dut/features/community_activity/presentation/widgets/common/status_label.dart';
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
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => CommunityActivityBloc(getIt.get<CommunityRepository>()),
        child: Scaffold(
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
                        (widget.userActivity.activity.image != null)
                            ? Image.network(
                                widget.userActivity.activity.image!,
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
                              Text(
                                widget.userActivity.activity.id,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: FontSizes.small,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.userActivity.activity.name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: FontSizes.medium,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              StatusLabel(
                                statusType: StatusType.userActivity,
                                statusCode: widget.userActivity.status,
                                isFullWidth: false,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.userActivity.activity.createdBy,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: FontSizes.small,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.userActivity.activity.subcategory.name,
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
                  child: ActivityInfo(activity: widget.userActivity.activity),
                )),
                if (widget.userActivity.status == UserActivityStatus.registered)
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
                                    width: 2,
                                  ),
                                ),
                              ),
                              onPressed: _cancelRegistration,
                              child: const Text('Hủy đăng ký'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF47B5C1),
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
                                    color: Color(0xFF47B5C1),
                                    width: 2,
                                  ),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text('Nộp minh chứng'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                if (widget.userActivity.status == UserActivityStatus.submitted)
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                            color: context.theme.primaryColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: GestureDetector(
                            onTap: () {
                              // Xử lý khi nhấn nút
                            },
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Đăng ký",
                                style: TextStyle(
                                    fontSize: FontSizes.medium,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            )),
                      )
                    ],
                  )
              ],
            ),
          ),
        ));
  }
}
