import 'package:auto_route/auto_route.dart';
import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/utils/getit_utils.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/common/widgets/loading/loading_progress_bar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/schedule/bloc/list_absent/list_absent_bloc.dart';
import 'package:e_dut/features/schedule/bloc/uos_detail/uos_detail_bloc.dart';
import 'package:e_dut/features/schedule/domain/repository/schedule_repo.dart';
import 'package:e_dut/features/schedule/presentation/widgets/detail_uos_tab/uos_info_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class DetailUOSScreen extends StatelessWidget {
  final String idUos;

  const DetailUOSScreen({super.key, required this.idUos});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final String userRole =
            authState is AuthUserAuthenticated
                ? authState.userData.role.name
                : '';
        final String authToken =
            authState is AuthUserAuthenticated ? authState.accessToken : '';
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create:
                  (_) => UosDetailBloc(getIt.get<ScheduleRepository>())..add(
                    LoadFullInfoUosDetail(
                      idUos: idUos,
                      isTeacher: false,
                      authToken: authToken,
                    ),
                  ),
            ),
            BlocProvider(
              create: (_) => ListAbsentBloc(getIt.get<ScheduleRepository>()),
            ),
          ],
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomAppbar(label: "Thông tin chi tiết học phần"),
            body:
                userRole == RoleModel.roleStudent
                    ? BlocBuilder<UosDetailBloc, UosDetailState>(
                      builder: (context, state) {
                        if (state is UosDetailLoading) {
                          return CustomLoadingIndicator.primary();
                        } else if (state is FullInfoUosLoaded) {
                          final uosFullInfo = state.fullInfoUosDetail;
                          return Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  uosFullInfo.uosDetail.subjectName,
                                  style: TextStyle(
                                    fontSize: FontSizes.extraLarge,
                                    fontWeight: FontWeight.bold,
                                    height: 1.25,
                                    color:
                                        context.theme.primaryColor ??
                                        Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: UosInfoTab(
                                    uosDetail: uosFullInfo.uosDetail,
                                    teacherName: uosFullInfo.teacherName,
                                    absentTimes: uosFullInfo.absentTimes,
                                    studyShifts: uosFullInfo.studyShifts,
                                    examShift: uosFullInfo.examShift,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'Không thể tải dữ liệu thông tin chi tiết học phần.',
                            ),
                          );
                        }
                      },
                    )
                    : Center(
                      child: Text(
                        'Bạn không có quyền truy cập vào chức năng này',
                        style: TextStyle(
                          fontSize: FontSizes.large,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
          ),
        );
      },
    );
  }
}
