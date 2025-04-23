import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/schedule/data/model/exam_shift_model.dart';
import 'package:e_dut/features/schedule/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnitOfStudyItem extends StatelessWidget {
  final String idUnitOfStudy;
  final String noUOS;
  final String nameSubject;
  final bool isExam;
  final int? credit;
  final Map<String, List<String>>? timetable;
  final ExamShiftModel? examShift;
  final String? room;
  final String? teacher;

  const UnitOfStudyItem({
    super.key,
    required this.idUnitOfStudy,
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
    final String userType =
        context.read<AuthBloc>().state is AuthUserAuthenticated
            ? (context.read<AuthBloc>().state as AuthUserAuthenticated)
                .userData
                .role
                .name
            : "Student";
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
            userType == "Student"
                ? Routes.detailUnitOfStudy
                : isExam
                    ? Routes.detailExamShiftTeacher
                    : Routes.detailUnitOfStudyTeacher,
            arguments: idUnitOfStudy);
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Color.fromRGBO(245, 245, 245, 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  noUOS,
                  style: TextStyle(
                      fontSize: FontSizes.small,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: context.theme.grey ?? Colors.grey),
                ),
                Text(
                  credit != null ? '$credit tín chỉ' : '',
                  style: TextStyle(
                      fontSize: FontSizes.small,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: context.theme.grey ?? Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              nameSubject,
              style: TextStyle(
                fontSize: FontSizes.large,
                fontWeight: FontWeight.bold,
                height: 1.25,
                color: isExam
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
                              fontSize: FontSizes.medium),
                        ),
                        const SizedBox(height: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: entry.value.map((shiftStr) {
                            return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
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
                                        fontSize: FontSizes.medium),
                                  ),
                                ));
                          }).toList(),
                        )
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
                  Text(
                    '${Functions.formatDateTime(examShift!.examDate)},  ${examShift!.room}',
                    style: TextStyle(
                      fontSize: FontSizes.medium,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Xuất ${examShift!.noExamShift}, nhóm ${examShift!.noExamGroup}',
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
  }
}
