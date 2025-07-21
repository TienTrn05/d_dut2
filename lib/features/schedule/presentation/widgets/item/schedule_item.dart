import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/exam_shift_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/data/model/role_model.dart';

class ScheduleItem extends StatelessWidget {
  final String idUos;
  final String subject;
  final String? time;
  final String room;
  final bool isExam;

  const ScheduleItem({
    super.key,
    required this.idUos,
    required this.subject,
    required this.time,
    required this.room,
    this.isExam = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      final String userRole = authState is AuthUserAuthenticated
          ? authState.userData.role.name
          : '';
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
              userRole == RoleModel.roleTeacher
                  ? isExam
                      ? Routes.detailExamShiftTeacher
                      : Routes.detailUnitOfStudyTeacher
                  : Routes.detailUnitOfStudy,
              arguments: userRole == RoleModel.roleTeacher
                  ? isExam
                      ? ExamShiftArgs(
                          idExamShift: idUos,
                          examShiftName: subject,
                        )
                      : idUos
                  : idUos);
        },
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 4),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.theme.lightGrey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: isExam
                            ? (context.theme.red ?? Colors.red)
                            : (context.theme.primaryColor ?? Colors.blue),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: TextStyle(
                            fontSize: FontSizes.medium,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                time ?? "",
                                style: TextStyle(
                                  fontSize: FontSizes.medium,
                                  height: 1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Text(
                              room,
                              style: TextStyle(
                                color: Color.fromRGBO(116, 116, 116, 1),
                                fontSize: FontSizes.medium,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              )),
            ],
          ),
        ),
      );
    });
  }
}
