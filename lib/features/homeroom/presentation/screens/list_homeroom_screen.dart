import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/utils/getit_utils.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/homeroom/bloc/list_homeroom_bloc.dart';
import 'package:e_dut/features/homeroom/presentation/widgets/items/homeroom_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repository/homeroom_repo.dart';

class ListHomeroomScreen extends StatelessWidget {
  ListHomeroomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppbar(label: "Danh sách lớp chủ nhiệm"),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
          final String userRole = authState is AuthUserAuthenticated
              ? authState.userData.role.name
              : '';
          if (userRole == RoleModel.roleTeacher) {
            return BlocProvider(
              create: (context) => ListHomeroomBloc(
                getIt<HomeroomRepository>(),
              )..add(ListHomeroomSubscriptionRequested(
                  token: authState is AuthUserAuthenticated
                      ? authState.accessToken
                      : '')),
              child: SafeArea(child:
                  BlocBuilder<ListHomeroomBloc, ListHomeroomState>(
                      builder: (context, state) {
                if (state is ListHomeroomLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ListHomeroomError) {
                  return Center(
                      child: Text(
                    'Đã có lỗi xảy ra: ${state.message}',
                    style: TextStyle(
                      fontSize: FontSizes.large,
                      fontStyle: FontStyle.normal,
                    ),
                  ));
                } else if (state is ListHomeroomLoaded) {
                  final homerooms = state.homerooms;
                  if (homerooms.isEmpty) {
                    return Center(
                        child: Text(
                      'Không có lớp chủ nhiệm nào',
                      style: TextStyle(
                        fontSize: FontSizes.large,
                        fontStyle: FontStyle.normal,
                      ),
                    ));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20.0,
                    children: [
                      // CohortSelector(cohortList: cohortList, currentCohort: currentCohort, onPrevious: onPrevious, onNext: onNext, onPickerSelected: onPickerSelected),
                      Text(
                        "${homerooms.length} lớp chủ nhiệm",
                        style: TextStyle(
                          fontSize: FontSizes.medium,
                          fontWeight: FontWeight.normal,
                          color: context.theme.grey,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            spacing: 4,
                            children: homerooms.map((homeroom) {
                              return HomeroomItem(homeroom: homeroom);
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Container();
              })),
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
      ),
    );
  }
}
