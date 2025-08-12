import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/homeroom/data/model/student_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentItem extends StatelessWidget {
  final StudentModel student;

  const StudentItem({super.key, required this.student});

  String maskCode(String code) {
    if (code.length <= 4) return code;
    int starCount = code.length - 4;
    return code.substring(0, 2) +
        '*' * starCount +
        code.substring(code.length - 2);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color.fromRGBO(116, 116, 116, 1),
                width: 0.5,
              ), // Chỉ border bottom
            ),
          ),
          child:
              BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
            final userRole = authState is AuthUserAuthenticated
                ? authState.userData.role.name
                : '';
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: TextStyle(
                                fontSize: FontSizes.medium,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true, // Cho phép xuống hàng
                              overflow: TextOverflow.visible, // Không cắt chữ
                            ),
                            Text(
                              userRole == RoleModel.roleStudent
                                  ? maskCode(student.studentCode)
                                  : student.mail,
                              style: TextStyle(
                                fontSize: FontSizes.small,
                              ),
                              softWrap: true, // Cho phép xuống hàng
                              overflow: TextOverflow.visible, // Không cắt chữ
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          })),
    );
  }
}
