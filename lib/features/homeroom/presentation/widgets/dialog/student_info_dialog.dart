import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/homeroom/data/model/student_model.dart';
import 'package:e_dut/features/homeroom/presentation/widgets/items/info_item.dart';
import 'package:flutter/material.dart';

class StudentInfoDialog extends StatelessWidget {
  final StudentModel student;
  const StudentInfoDialog({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16.0)),
      child: Container(
        padding: const EdgeInsetsDirectional.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 16.0,
          children: [
            Text(
              student.name,
              style: TextStyle(
                fontSize: FontSizes.large,
                fontWeight: FontWeight.w900,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 8.0,
              children: [
                InfoItem(field: "MSSV", value: student.studentCode),
                InfoItem(field: "SĐT", value: student.phoneNumber),
                InfoItem(field: "Email cá nhân", value: student.mail),
                InfoItem(
                    field: "SĐT người thân",
                    value: student.relativePhoneNumber),
              ],
            ),
            Divider(color: context.theme.primaryColor ?? Colors.blue),
            Text(
              'Thông tin liên hệ',
              style: TextStyle(
                  fontSize: FontSizes.extraLarge,
                  fontWeight: FontWeight.w900,
                  color: context.theme.primaryColor ?? Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
