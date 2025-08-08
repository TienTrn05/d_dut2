import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/homeroom/data/model/homeroom_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListHomeroomScreen extends StatelessWidget {
  ListHomeroomScreen({super.key});

  List<HomeroomModel> homerooms = [
    HomeroomModel(name: "21TCLC_DT2", numStudent: 47),
    HomeroomModel(name: "21T_DT2", numStudent: 80)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppbar(label: "Danh sách lớp chủ nhiệm"),
      body: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
        final String userRole = authState is AuthUserAuthenticated
            ? authState.userData.role.name
            : '';
        if (userRole == RoleModel.roleTeacher) {
          return Center(
            child: Text('Danh sách các lớp chủ nhiệm'),
          );
        } else {
          return Center(
            child: Text(
              'Bạn không có quyền truy cập vào chức năng này',
              style: TextStyle(
                fontSize: FontSizes.large,
                fontStyle: FontStyle.normal,
              ),
            ),
          );
        }
      }),
    );
  }
}
