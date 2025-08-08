import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/schedule/data/model/unit_of_study/exam_shift_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/extensions/custom_theme_extension.dart';

class ScheduleItem extends StatelessWidget {
  final String idSubject;
  final String subject;
  final String time;
  final String room;
  final bool isExam;

  const ScheduleItem(
      {super.key,
      required this.idSubject,
      required this.subject,
      required this.time,
      required this.room,
      this.isExam = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      final String userRole = authState is AuthUserAuthenticated
          ? authState.userData.role.name
          : '';
      final String authToken =
          authState is AuthUserAuthenticated ? authState.accessToken : '';

      return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
                userRole == RoleModel.roleStudent
                    ? Routes.detailUnitOfStudy
                    : isExam
                        ? Routes.detailExamShiftTeacher
                        : Routes.detailUnitOfStudyTeacher,
                arguments: userRole == RoleModel.roleTeacher
                    ? isExam
                        ? ExamShiftArgs(
                            idExamShift: idSubject,
                            examShiftName: subject,
                            authToken: authToken)
                        : idSubject
                    : idSubject);
          },
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 4),
            padding: EdgeInsets.only(left: 6, right: 8, top: 4, bottom: 4),
            decoration: BoxDecoration(
              color: context.theme.lightGrey,
              borderRadius: BorderRadius.circular(4),
              border: Border(
                left: BorderSide(
                  color: isExam
                      ? (context.theme.red ?? Colors.red)
                      : (context.theme.primaryColor ?? Colors.blue),
                  width: 2,
                ),
              ),
            ),
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
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: FontSizes.medium,
                            height: 1.25,
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
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ));
    });
  }
}
