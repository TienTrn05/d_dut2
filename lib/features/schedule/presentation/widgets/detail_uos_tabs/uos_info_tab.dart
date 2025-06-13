import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/snackbar/custom_snackbar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/profile/presentation/widgets/info_item.dart';
import 'package:e_dut/features/schedule/data/model/study_shift_model.dart';
import 'package:e_dut/features/schedule/presentation/widgets/cards/absents_card.dart';
import 'package:e_dut/features/schedule/presentation/widgets/cards/uos_info_card.dart';
import 'package:e_dut/features/schedule/presentation/widgets/custom/bottom_modal.dart';
import 'package:e_dut/features/schedule/presentation/widgets/items/edit_field_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/items/uos_info_item.dart';
import 'package:e_dut/features/schedule/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class UosInfoTab extends StatefulWidget {
  final String idUos;
  const UosInfoTab({super.key, required this.idUos});

  @override
  State<UosInfoTab> createState() => _UosInfoTabState();
}

class _UosInfoTabState extends State<UosInfoTab> {
  final TextEditingController _codeController =
      TextEditingController(text: "012ajsh");
  final TextEditingController _linkController = TextEditingController(
      text:
          "https://teams.microsoft.com/l/team/19%3Ad2pYw4aOqMVmggq1SStgmgoce9mEfA73aKGb_UzJbzQ1%40thread.tacv2/conversations?groupId=c2aeacc4-5d26-466b-a6be-ffb69ccfe8de&tenantId=42350984-d0f6-4a38-978a-aa84e495e429");

  void _showEditLinkModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return BottomModal(
            title: "Giảng dạy",
            mainAction: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: Column(
              children: [
                EditFieldItem(
                  field: "Mã truy cập",
                  controller: _codeController,
                ),
                const SizedBox(height: 10),
                EditFieldItem(
                  field: "Đường link truy cập",
                  controller: _linkController,
                  minLine: 5,
                )
              ],
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> timetable = Functions.analyzeStudyShifts([
      StudyShiftModel(
          dayOfWeek: 1,
          startPeriod: 1,
          endPeriod: 3,
          startWeek: 3,
          endWeek: 18,
          room: "E201A"),
      StudyShiftModel(
          dayOfWeek: 2,
          startPeriod: 1,
          endPeriod: 3,
          startWeek: 3,
          endWeek: 19,
          room: "E201A"),
      StudyShiftModel(
          dayOfWeek: 3,
          startPeriod: 1,
          endPeriod: 3,
          startWeek: 3,
          endWeek: 19,
          room: "E201A"),
    ]);
    final entries = timetable.entries.toList();
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      final String userRole = authState is AuthUserAuthenticated
          ? authState.userData.role.name
          : '';
      return SingleChildScrollView(
        child: Column(
          children: [
            UosInfoCard(
              title: 'Thông tin chung',
              child: Column(
                children: [
                  InfoItem(
                      field: "Mã lớp học phần", value: "1024010.2420.21.11"),
                  InfoItem(field: "Mã môn", value: "123456"),
                  InfoItem(
                    field: "Hệ",
                    value: "CLC",
                  ),
                  InfoItem(
                    field: "Số tín chỉ",
                    value: "03",
                  ),
                  InfoItem(
                    field: "Kỳ học",
                    value: "Học kì 1, 2025-2026",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            UosInfoCard(
              title: 'Giảng dạy',
              canEdit: userRole == RoleModel.roleTeacher,
              action: () => _showEditLinkModal(context),
              child: Column(
                children: [
                  if (userRole != RoleModel.roleTeacher)
                    InfoItem(field: "Giảng viên", value: "Đặng Thiên Bình"),
                  InfoItem(field: "Hình thức GD", value: "Offline & Online"),
                  UosInfoItem(
                    field: "Mã truy cập",
                    value: (_codeController.text.trim().isNotEmpty)
                        ? Text(
                            _codeController.text,
                            style: TextStyle(
                              fontSize: FontSizes.medium,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.5,
                            ),
                          )
                        : Text(
                            "Chưa cập nhật",
                            style: TextStyle(
                              fontSize: FontSizes.medium,
                              fontStyle: FontStyle.italic,
                              color: context.theme.grey ?? Colors.grey,
                              height: 1.5,
                            ),
                          ),
                    linkIconAsset: (_codeController.text.trim().isNotEmpty)
                        ? "assets/icons/svg/lucide_copy.svg"
                        : null,
                    action: () {
                      try {
                        Clipboard.setData(
                            ClipboardData(text: _codeController.text));
                        // debugPrint("Copied: 012ajsh");
                        CustomSnackbar.showSnackBar(
                          context,
                          "Thành công",
                          "Đã sao chép mã ${_codeController.text}",
                          AlertType.success,
                        );
                      } catch (e) {
                        CustomSnackbar.showSnackBar(
                          context,
                          "Lỗi",
                          "Không thể sao chép",
                          AlertType.error,
                        );
                      }
                    },
                  ),
                  UosInfoItem(
                    field: "Link tham gia",
                    value: (_linkController.text.trim().isNotEmpty)
                        ? GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse("");
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else if (context.mounted) {
                                CustomSnackbar.showSnackBar(
                                  context,
                                  "Lỗi",
                                  "Không thể truy cập link",
                                  AlertType.error,
                                );
                              }
                            },
                            child: Text(
                              "Link tham gia Teams",
                              style: TextStyle(
                                fontSize: FontSizes.medium,
                                fontWeight: FontWeight.w400,
                                color:
                                    context.theme.primaryColor ?? Colors.blue,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    context.theme.primaryColor ?? Colors.blue,
                                height: 1.5,
                              ),
                            ),
                          )
                        : Text(
                            "Chưa cập nhật",
                            style: TextStyle(
                              fontSize: FontSizes.medium,
                              fontStyle: FontStyle.italic,
                              color: context.theme.grey ?? Colors.grey,
                              height: 1.5,
                            ),
                          ),
                    linkIconAsset: (_linkController.text.trim().isNotEmpty)
                        ? "assets/icons/svg/lucide_copy.svg"
                        : null,
                    action: () {
                      try {
                        Clipboard.setData(
                            ClipboardData(text: _linkController.text));
                        // debugPrint("Copied: 012ajsh");
                        CustomSnackbar.showSnackBar(
                          context,
                          "Thành công",
                          "Đã sao chép đường link",
                          AlertType.success,
                        );
                      } catch (e) {
                        CustomSnackbar.showSnackBar(
                          context,
                          "Lỗi",
                          "Không thể sao chép",
                          AlertType.error,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            UosInfoCard(
              title: 'Đánh giá',
              child: Column(
                children: [
                  if (userRole == RoleModel.roleStudent)
                    UosInfoItem(
                        field: "Số lần vắng",
                        value: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => const AbsentsCard(
                                  isTeacher: false,
                                  absentDates: ["10/09/2023", "11/09/2023"]),
                            );
                          },
                          child: Text(
                            "3",
                            style: TextStyle(
                              fontSize: FontSizes.medium,
                              fontWeight: FontWeight.bold,
                              color: context.theme.red ?? Colors.red,
                              decoration: TextDecoration.underline,
                              decorationColor: context.theme.red ?? Colors.red,
                              height: 1.5,
                            ),
                          ),
                        )),
                  InfoItem(
                      field: "Công thức điểm",
                      value: "[GK]*0.20+[BT]*0.20+[CK]*0.60"),
                ],
              ),
            ),
            const SizedBox(height: 10),
            UosInfoCard(
                title: userRole == RoleModel.roleTeacher
                    ? 'Thời khóa biểu'
                    : 'Lịch học',
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(entries.length, (index) {
                      final entry = entries[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tuần ${entry.key}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSizes.medium,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...entry.value.map((shiftStr) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color:
                                              context.theme.grey ?? Colors.grey,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      shiftStr,
                                      style: TextStyle(
                                        color:
                                            context.theme.grey ?? Colors.grey,
                                        fontSize: FontSizes.medium,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                          if (index < entries.length - 1)
                            const SizedBox(height: 10),
                        ],
                      );
                    }),
                  ),
                )),
            const SizedBox(height: 10),
            if (userRole == RoleModel.roleStudent)
              UosInfoCard(
                title: 'Lịch thi',
                child: Column(
                  children: [
                    InfoItem(field: "Ngày giờ", value: "7:00, 14/5/2025"),
                    InfoItem(field: "Phòng", value: "207"),
                    InfoItem(field: "Xuất", value: "2C1"),
                    InfoItem(field: "Nhóm", value: "A"),
                    InfoItem(field: "Hình thức thi", value: "Thi chung"),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}
