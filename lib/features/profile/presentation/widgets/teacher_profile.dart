import 'package:e_dut/features/community_activity/util/functions.dart';
import 'package:e_dut/features/profile/data/model/teacher_profile_model.dart';
import 'package:e_dut/features/profile/presentation/widgets/info_card.dart';
import 'package:e_dut/features/profile/presentation/widgets/info_item.dart';
import 'package:flutter/material.dart';

class TeacherProfile extends StatelessWidget {
  final TeacherProfileModel profile;

  const TeacherProfile({super.key, required this.profile});

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
                InfoItem(field: "Mã CBVC", value: profile.employeeId),
                InfoItem(
                  field: "Địa chỉ cư trú",
                  value: profile.address,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          InfoCard(
            title: "Thông tin công tác",
            child: Column(
              spacing: 4,
              children: [
                InfoItem(field: "Học vị", value: profile.degree),
                InfoItem(field: "Học hàm", value: profile.academicTitle),
                InfoItem(field: "Đơn vị công tác", value: profile.department),
                InfoItem(field: "Chức danh", value: profile.position),
                InfoItem(
                    field: "Năm công tác",
                    value: profile.yearsOfService.toString()),
                InfoItem(
                    field: "Hệ số PC",
                    value: profile.salaryCoefficient.toString()),
                InfoItem(field: "STK", value: profile.bankAccount),
              ],
            ),
          ),
          const SizedBox(height: 10),
          InfoCard(
            title: "Thông tin học vấn",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Column(
                  spacing: 4,
                  children: [
                    InfoItem(
                      field: "Bằng Đại học ngành",
                      value: profile.bachelorDegreeField,
                    ),
                    InfoItem(
                      field: "Năm",
                      value: profile.bachelorGraduationYear.toString(),
                    ),
                    InfoItem(
                      field: "Tại nước",
                      value: profile.bachelorCountry,
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  width: 120,
                  color: Color(0xFFD9D9D9),
                ),
                Column(
                  spacing: 4,
                  children: [
                    InfoItem(
                      field: "Bằng Thạc sĩ ngành",
                      value: profile.masterDegreeField,
                    ),
                    InfoItem(
                      field: "Năm",
                      value: profile.masterGraduationYear.toString(),
                    ),
                    InfoItem(
                      field: "Tại nước",
                      value: profile.masterCountry!,
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  width: 120,
                  color: Color(0xFFD9D9D9),
                ),
                Column(
                  spacing: 4,
                  children: [
                    InfoItem(
                      field: "Bằng Tiến sĩ ngành",
                      value: profile.doctorateField,
                    ),
                    InfoItem(
                      field: "Năm",
                      value: profile.doctorateGraduationYear.toString(),
                    ),
                    InfoItem(
                      field: "Tại nước",
                      value: profile.doctorateCountry!,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
