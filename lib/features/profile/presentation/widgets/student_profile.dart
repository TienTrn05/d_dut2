import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/profile/data/model/student_profile_model.dart';
import 'package:e_dut/features/profile/presentation/widgets/info_card.dart';
import 'package:e_dut/features/profile/presentation/widgets/info_item.dart';
import 'package:e_dut/features/schedule/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentProfile extends StatelessWidget {
  final StudentProfileModel profile;
  const StudentProfile({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
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
                    value: Functions.formatDate(profile.dateOfBirth)),
                InfoItem(field: "Giới tính", value: profile.gender),
                InfoItem(
                  field: "Số điện thoại",
                  value: profile.phoneNumber,
                ),
                InfoItem(
                  field: "Email cá nhân",
                  value: profile.personalEmail,
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
                InfoItem(field: "Ngành", value: profile.major),
                InfoItem(field: "Lớp", value: profile.homeroom),
                InfoItem(field: "CTĐT", value: profile.trainingProgram),
                BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                  final String email = (state is AuthUserAuthenticated)
                      ? state.userData.mail
                      : 'Unknown';
                  return InfoItem(field: "TK Office365", value: email);
                })
              ],
            ),
          ),
          const SizedBox(height: 10),
          InfoCard(
            title: "Thông tin liên hệ khẩn cấp",
            child: Column(
              spacing: 4,
              children: [
                InfoItem(
                  field: "Họ tên/Quan hệ",
                  value: profile.relativeName,
                ),
                InfoItem(
                  field: "SĐT",
                  value: profile.relativePhoneNumber,
                ),
                InfoItem(
                  field: "Số nhà đường",
                  value: profile.address,
                ),
                InfoItem(
                  field: "Tỉnh/Thành phố",
                  value: profile.city,
                ),
                InfoItem(
                  field: "Xã/Phường",
                  value: profile.ward,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
