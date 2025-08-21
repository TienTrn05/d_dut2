import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/extensions/font_sizes.dart';
import '/common/utils/getit_utils.dart';

import '/features/auth/bloc/auth_bloc.dart';
import '/features/schedule/util/functions.dart';

import '../../bloc/student_profile/student_profile_bloc.dart';
import '../../domain/repository/profile_repository.dart';
import './info_card.dart';
import './info_item.dart';

class StudentProfile extends StatelessWidget {
  const StudentProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is! AuthUserAuthenticated) {
        return Center(
          child: Text(
            'Bạn cần đăng nhập để sử dụng tính năng này.',
            style: TextStyle(fontSize: FontSizes.large),
          ),
        );
      }

      return BlocProvider(
        create: (context) =>
            StudentProfileBloc(repository: getIt.get<ProfileRepository>())
              ..add(LoadStudentProfile(
                authState.accessToken,
              )),
        child: BlocBuilder<StudentProfileBloc, StudentProfileState>(
          builder: (context, profileState) {
            if (profileState.studentProfileStatus ==
                StudentProfileStatus.loading || profileState.studentProfileStatus ==
                StudentProfileStatus.initial) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (profileState.studentProfileStatus ==
                StudentProfileStatus.failure) {
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
                            value: profileState.profile!.dateOfBirth != null ? Functions.formatDate(profileState.profile!.dateOfBirth!) : "Chưa cập nhật"),
                        InfoItem(field: "Giới tính", value: profileState.profile!.gender),
                        InfoItem(
                          field: "Số điện thoại",
                          value: profileState.profile!.phoneNumber,
                        ),
                        InfoItem(
                          field: "Email cá nhân",
                          value: profileState.profile!.personalEmail,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  InfoCard(
                    title: "Thông tin học vấn",
                    child: Column(
                      spacing: 4,
                      children: [
                        InfoItem(field: "Ngành", value: profileState.profile!.major),
                        InfoItem(field: "Lớp", value: profileState.profile!.homeroom),
                        InfoItem(field: "CTĐT", value: profileState.profile!.trainingProgram),
                        BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                          final String email = (state is AuthUserAuthenticated)
                              ? state.userData.mail
                              : 'Unknown';
                          return InfoItem(field: "TK Office365", value: email);
                        })
                      ],
                    ),
                  ),
                  // const SizedBox(height: 10),
                  // InfoCard(
                  //   title: "Thông tin liên hệ khẩn cấp",
                  //   child: Column(
                  //     spacing: 4,
                  //     children: [
                  //       InfoItem(
                  //         field: "Họ tên/Quan hệ",
                  //         value: profileState.profile!.relativeName,
                  //       ),
                  //       InfoItem(
                  //         field: "SĐT",
                  //         value: profileState.profile!.relativePhoneNumber,
                  //       ),
                  //       InfoItem(
                  //         field: "Số nhà đường",
                  //         value: profileState.profile!.address,
                  //       ),
                  //       InfoItem(
                  //         field: "Tỉnh/Thành phố",
                  //         value: profileState.profile!.city,
                  //       ),
                  //       InfoItem(
                  //         field: "Xã/Phường",
                  //         value: profileState.profile!.ward,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            );
          }
        ),
      );
    });
  }
}
