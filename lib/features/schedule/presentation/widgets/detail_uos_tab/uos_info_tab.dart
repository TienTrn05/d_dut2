import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart' as dialog;
import 'package:e_dut/common/widgets/snackbar/custom_snackbar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/profile/presentation/widgets/info_item.dart';
import 'package:e_dut/features/schedule/bloc/list_absent/list_absent_bloc.dart';
import 'package:e_dut/features/schedule/bloc/uos_detail/uos_detail_bloc.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/exam_shift_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/study_shift_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/uos_detail_model.dart';
import 'package:e_dut/features/schedule/presentation/widgets/card/absents_card.dart';
import 'package:e_dut/features/schedule/presentation/widgets/card/uos_info_card.dart';
import 'package:e_dut/common/widgets/modal/bottom_modal.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/edit_field_item.dart';
import 'package:e_dut/features/schedule/presentation/widgets/item/uos_info_item.dart';
import 'package:e_dut/features/schedule/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class UosInfoTab extends StatefulWidget {
  final UosDetailModel uosDetail;
  final String? teacherName;
  final int? absentTimes;
  final List<StudyShiftModel> studyShifts;
  final ExamShiftModel? examShift;
  const UosInfoTab({
    super.key,
    required this.uosDetail,
    this.teacherName,
    this.absentTimes,
    required this.studyShifts,
    this.examShift,
  });

  @override
  State<UosInfoTab> createState() => _UosInfoTabState();
}

class _UosInfoTabState extends State<UosInfoTab> {
  late TextEditingController _codeController;
  late TextEditingController _linkController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.uosDetail.msTeamCode);
    _linkController = TextEditingController(text: widget.uosDetail.msTeamLink);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _showEditLinkModal(UosDetailBloc detailBloc, String authToken) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return BottomModal(
          title: "Giảng dạy",
          mainAction: () {
            dialog.CustomAlertDialog.showCustomDialog(
              context,
              "Xác nhận cập nhật thông tin",
              "Bạn có chắc chắn muốn cập nhật thông tin giảng dạy không\"?",
              textCancel: "Đóng",
              dialog.AlertDialogType.confirm,
              textConfirm: "Xác nhận",
              onConfirm: () {
                detailBloc.add(
                  UpdateMsTeamsInfo(
                    idUos: widget.uosDetail.idUnitOfStudy,
                    authToken: authToken,
                    msTeamCode: _codeController.text.trim(),
                    msTeamLink: _linkController.text.trim(),
                  ),
                );
                setState(() {});
                Navigator.pop(context);
              },
            );
          },
          child: Column(
            children: [
              EditFieldItem(field: "Mã truy cập", controller: _codeController),
              const SizedBox(height: 10),
              EditFieldItem(
                field: "Đường link truy cập",
                controller: _linkController,
                minLine: 5,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> timetable = Functions.analyzeStudyShifts(
      widget.studyShifts,
    );
    final entries = timetable.entries.toList();
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final String userRole =
            authState is AuthUserAuthenticated
                ? authState.userData.role.name
                : '';
        final String authToken =
            authState is AuthUserAuthenticated ? authState.accessToken : '';
        return RefreshIndicator(
          color: context.theme.primaryColor,
          backgroundColor: Colors.white,
          onRefresh: () async {
            context.read<UosDetailBloc>().add(
              LoadFullInfoUosDetail(
                idUos: widget.uosDetail.idUnitOfStudy,
                isTeacher: userRole == RoleModel.roleTeacher,
                authToken: authToken,
              ),
            );
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                UosInfoCard(
                  title: 'Thông tin chung',
                  child: Column(
                    children: [
                      InfoItem(
                        field: "Mã lớp học phần",
                        value: widget.uosDetail.noUOS,
                      ),
                      InfoItem(
                        field: "Mã môn",
                        value: widget.uosDetail.noSubject,
                      ),
                      // InfoItem(
                      //   field: "Hệ",
                      //   value: widget.uosDetail.clc == 1 ? "CLC" : "",
                      // ),
                      InfoItem(
                        field: "Số tín chỉ",
                        value: widget.uosDetail.credit.toString(),
                      ),
                      InfoItem(
                        field: "Kỳ học",
                        value: widget.uosDetail.semester,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                UosInfoCard(
                  title: 'Giảng dạy',
                  canEdit: userRole == RoleModel.roleTeacher,
                  action:
                      () => _showEditLinkModal(
                        context.read<UosDetailBloc>(),
                        authToken,
                      ),
                  child: Column(
                    children: [
                      if (userRole == RoleModel.roleStudent)
                        InfoItem(
                          field: "Giảng viên",
                          value: widget.teacherName!,
                        ),
                      InfoItem(
                        field: "Hình thức GD",
                        value: widget.uosDetail.methodOfTeaching,
                      ),
                      UosInfoItem(
                        field: "Mã truy cập",
                        value:
                            (_codeController.text.trim().isNotEmpty)
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
                        linkIconAsset:
                            (_codeController.text.trim().isNotEmpty)
                                ? "assets/icons/svg/lucide_copy.svg"
                                : null,
                        action: () {
                          try {
                            Clipboard.setData(
                              ClipboardData(text: _codeController.text),
                            );
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
                        value:
                            (_linkController.text.trim().isNotEmpty)
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
                                          context.theme.primaryColor ??
                                          Colors.blue,
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.underline,
                                      decorationColor:
                                          context.theme.primaryColor ??
                                          Colors.blue,
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
                        linkIconAsset:
                            (_linkController.text.trim().isNotEmpty)
                                ? "assets/icons/svg/lucide_copy.svg"
                                : null,
                        action: () {
                          try {
                            Clipboard.setData(
                              ClipboardData(text: _linkController.text),
                            );
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
                                builder:
                                    (dialogContext) => BlocProvider.value(
                                      value: context.read<ListAbsentBloc>(),
                                      child: AbsentsCard(
                                        isTeacher: false,
                                        idUos: widget.uosDetail.idUnitOfStudy,
                                        idStudent: '',
                                      ),
                                    ),
                              );
                            },
                            child: Text(
                              widget.absentTimes!.toString(),
                              style: TextStyle(
                                fontSize: FontSizes.medium,
                                fontWeight: FontWeight.bold,
                                color: context.theme.red ?? Colors.red,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    context.theme.red ?? Colors.red,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      InfoItem(
                        field: "Công thức điểm",
                        value: widget.uosDetail.scoreFormula,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                UosInfoCard(
                  title:
                      userRole == RoleModel.roleTeacher
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            color:
                                                context.theme.grey ??
                                                Colors.grey,
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
                  ),
                ),
                const SizedBox(height: 10),
                if (userRole == RoleModel.roleStudent)
                  if (widget.examShift != null &&
                      widget.examShift!.idExamShift.isNotEmpty)
                    UosInfoCard(
                      title: 'Lịch thi',
                      child: Column(
                        children: [
                          InfoItem(
                            field: "Ngày giờ",
                            value:
                                widget.examShift!.examDate != null
                                    ? Functions.formatDateTime(
                                      widget.examShift!.examDate!,
                                    )
                                    : '',
                          ),
                          InfoItem(
                            field: "Phòng",
                            value: widget.examShift!.room,
                          ),
                          InfoItem(
                            field: "Xuất",
                            value: widget.examShift!.noExamShift,
                          ),
                          InfoItem(
                            field: "Nhóm",
                            value: widget.examShift!.noExamGroup,
                          ),
                          InfoItem(
                            field: "Hình thức thi",
                            value: widget.examShift!.methodOfExam,
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}
