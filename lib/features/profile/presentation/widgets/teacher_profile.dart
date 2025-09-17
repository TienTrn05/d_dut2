import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/extensions/font_sizes.dart';
import '/common/utils/getit_utils.dart';

import '../../bloc/teacher_profile/teacher_profile_bloc.dart';
import '../../domain/repository/profile_repository.dart';

import '/features/auth/bloc/auth_bloc.dart';
import '/features/community_activity/util/functions.dart';
import './info_card.dart';
import './info_item.dart';

class TeacherProfile extends StatelessWidget {
  const TeacherProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is! AuthUserAuthenticated) {
        return Center(
          child: Text(
            'Bạn cần đăng nhập để sử dụng tính năng này.',
            style: TextStyle(fontSize: FontSizes.large),
            textAlign: TextAlign.center,
          ),
        );
      }

      return BlocProvider(
        create: (context) =>
            TeacherProfileBloc(repository: getIt.get<ProfileRepository>())
              ..add(LoadTeacherProfile(
                authState.accessToken,
              )),
        child: BlocBuilder<TeacherProfileBloc, TeacherProfileState>(
            builder: (context, profileState) {
          if (profileState.teacherProfileStatus ==
                  TeacherProfileStatus.loading ||
              profileState.teacherProfileStatus ==
                  TeacherProfileStatus.initial) {
            return Center(
              child: CircularProgressIndicator(
                color: context.theme.primaryColor,
              ),
            );
          } else if (profileState.teacherProfileStatus ==
              TeacherProfileStatus.failure) {
            return Center(
              child: Text(
                'Lỗi khi tải thông tin',
                style: TextStyle(fontSize: FontSizes.large),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                InfoCard(
                  title: "Thông tin cơ bản",
                  child: Column(
                    spacing: 4,
                    children: [
                      InfoItem(
                          field: "Ngày sinh",
                          value: profileState.profile!.dateOfBirth != null
                              ? Functions.formatDate(
                                  profileState.profile!.dateOfBirth!)
                              : "Chưa cập nhật"),
                      // InfoItem(field: "Mã CBVC", value: profile.employeeId),
                      // InfoItem(
                      //   field: "Địa chỉ cư trú",
                      //   value: profile.address,
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                InfoCard(
                  title: "Thông tin công tác",
                  child: Column(
                    spacing: 4,
                    children: [
                      // InfoItem(field: "Học vị", value: profile.degree),
                      // InfoItem(field: "Học hàm", value: profile.academicTitle),
                      InfoItem(
                          field: "Đơn vị công tác",
                          value: profileState.profile!.department),
                      // InfoItem(field: "Chức danh", value: profile.position),
                      // InfoItem(
                      //     field: "Năm công tác",
                      //     value: profile.yearsOfService.toString()),
                      // InfoItem(
                      //     field: "Hệ số PC",
                      //     value: profile.salaryCoefficient.toString()),
                      // InfoItem(field: "STK", value: profile.bankAccount),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // InfoCard(
                //   title: "Thông tin học vấn",
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     spacing: 10,
                //     children: [
                //       Column(
                //         spacing: 4,
                //         children: [
                //           InfoItem(
                //             field: "Bằng Đại học ngành",
                //             value: profile.bachelorDegreeField,
                //           ),
                //           InfoItem(
                //             field: "Năm",
                //             value: profile.bachelorGraduationYear.toString(),
                //           ),
                //           InfoItem(
                //             field: "Tại nước",
                //             value: profile.bachelorCountry,
                //           ),
                //         ],
                //       ),
                //       Container(
                //         height: 1,
                //         width: 120,
                //         color: Color(0xFFD9D9D9),
                //       ),
                //       Column(
                //         spacing: 4,
                //         children: [
                //           InfoItem(
                //             field: "Bằng Thạc sĩ ngành",
                //             value: profile.masterDegreeField,
                //           ),
                //           InfoItem(
                //             field: "Năm",
                //             value: profile.masterGraduationYear.toString(),
                //           ),
                //           InfoItem(
                //             field: "Tại nước",
                //             value: profile.masterCountry!,
                //           ),
                //         ],
                //       ),
                //       Container(
                //         height: 1,
                //         width: 120,
                //         color: Color(0xFFD9D9D9),
                //       ),
                //       Column(
                //         spacing: 4,
                //         children: [
                //           InfoItem(
                //             field: "Bằng Tiến sĩ ngành",
                //             value: profile.doctorateField,
                //           ),
                //           InfoItem(
                //             field: "Năm",
                //             value: profile.doctorateGraduationYear.toString(),
                //           ),
                //           InfoItem(
                //             field: "Tại nước",
                //             value: profile.doctorateCountry!,
                //           ),
                //         ],
                //       )
                //     ],
                //   ),
                // ),
              ],
            ),
          );
        }),
      );
    });
  }
}
