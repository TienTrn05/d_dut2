import 'package:auto_route/auto_route.dart';
import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/exam_shift_model.dart';
import 'package:e_dut/features/schedule/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';

class UnitOfStudyItem extends StatelessWidget {
  final String? idUos;
  final String noUOS;
  final String nameSubject;
  final bool isExam;
  final num? credit;
  final Map<String, List<String>>? timetable;
  final ExamShiftModel? examShift;
  final String? room;
  final String? teacher;

  const UnitOfStudyItem({
    super.key,
    required this.idUos,
    required this.noUOS,
    required this.nameSubject,
    this.isExam = false,
    this.credit,
    this.timetable,
    this.examShift,
    this.room,
    this.teacher,
  });

  @override
  Widget build(BuildContext context) {
    final hasShift = examShift?.noExamShift.isNotEmpty ?? false;
    final hasGroup = examShift?.noExamGroup.isNotEmpty ?? false;

    String displayGroupShiftText = '';
    if (hasShift && hasGroup) {
      displayGroupShiftText =
          'Xuất ${examShift!.noExamShift}, nhóm ${examShift!.noExamGroup}';
    } else if (hasShift) {
      displayGroupShiftText = 'Xuất ${examShift!.noExamShift}';
    } else if (hasGroup) {
      displayGroupShiftText = 'Nhóm ${examShift!.noExamGroup}';
    }
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final String userRole =
            authState is AuthUserAuthenticated
                ? authState.userData.role.name
                : '';
        final String authToken =
            authState is AuthUserAuthenticated ? authState.accessToken : '';
        return GestureDetector(
          onTap: () {
            if (userRole == RoleModel.roleStudent) {
              context.router.push(DetailUOSRoute(idUos: idUos!));
            } else if (userRole == RoleModel.roleTeacher) {
              if (isExam) {
                context.router.push(
                  DetailExamShiftRoute(
                    idExamShift: examShift!.idExamShift,
                    examShiftName:
                        userRole == RoleModel.roleTeacher
                            ? examShift!.examShiftName
                            : nameSubject,
                    authToken: authToken,
                  ),
                );
              } else {
                context.router.push(
                  DetailUOSTeacherRoute(
                    idUos: idUos!,
                    selectedDay: DateTime.now(),
                  ),
                );
              }
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.theme.lightGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (noUOS.isNotEmpty || examShift!.examShiftName.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isExam
                            ? userRole == RoleModel.roleTeacher
                                ? examShift!.examCode
                                : noUOS
                            : noUOS,
                        style: TextStyle(
                          fontSize: FontSizes.small,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                          color: context.theme.grey ?? Colors.grey,
                        ),
                      ),
                      Text(
                        credit != null ? '$credit tín chỉ' : '',
                        style: TextStyle(
                          fontSize: FontSizes.small,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                          color: context.theme.grey ?? Colors.grey,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Text(
                  isExam
                      ? userRole == RoleModel.roleTeacher
                          ? examShift!.examShiftName
                          : nameSubject
                      : nameSubject,
                  style: TextStyle(
                    fontSize: FontSizes.large,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                    color:
                        isExam
                            ? context.theme.red ?? Colors.red
                            : context.theme.primaryColor ?? Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                ...(timetable?.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tuần ${entry.key}', // ví dụ: "Tuần 31-32"
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: FontSizes.medium,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  entry.value.map((shiftStr) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                        ),
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
                                                context.theme.grey ??
                                                Colors.grey,
                                            fontSize: FontSizes.medium,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      );
                    }).toList() ??
                    []),
                const SizedBox(height: 4),
                if (examShift != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (examShift!.examDate != null)
                        Text(
                          '${Functions.formatDateTime(examShift!.examDate!)},  ${examShift!.room}',
                          style: TextStyle(
                            fontSize: FontSizes.medium,
                            height: 1.25,
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (displayGroupShiftText.trim().isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              displayGroupShiftText,
                              style: TextStyle(
                                color: context.theme.grey ?? Colors.grey,
                                fontSize: FontSizes.medium,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                (teacher != null)
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'GV: $teacher',
                          style: TextStyle(
                            color: context.theme.grey ?? Colors.grey,
                            fontSize: FontSizes.medium,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.25,
                          ),
                        ),
                      ],
                    )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }
}
