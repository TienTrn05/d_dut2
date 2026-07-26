import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/homeroom/data/model/student_model.dart';
import 'package:e_dut/features/homeroom/presentation/widgets/items/info_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class StudentInfoDialog extends StatelessWidget {
  final StudentModel student;
  const StudentInfoDialog({super.key, required this.student});

  Widget _buildDetailedBadge(String baseStatus, String detailedText) {
    Color color;
    IconData icon;
    double iconSize = 12.0;

    switch (baseStatus) {
      case 'Cảnh báo (Lần 1)':
        color = const Color(0XFFD69700);
        icon = MaterialCommunityIcons.bell;
        break;
      case 'Cảnh báo (Lần 2)':
        color = const Color(0XFFFF8D28);
        icon = MaterialCommunityIcons.bell_ring;
        break;
      case 'Ngừng học':
        color = const Color(0XFF606166);
        icon = Icons.pause_rounded;
        break;
      case 'Buộc thôi học':
        color = const Color(0XFFF20014);
        icon = Icons.block_rounded;
        break;
      case 'Bình thường':
      default:
        color = const Color(0xFF5BA876);
        icon = Icons.circle;
        iconSize = 10.0;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color, width: 0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              detailedText,
              style: TextStyle(
                fontSize: FontSizes.small,
                color: color,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusList() {
    if (student.warnings.isEmpty) {
      return _buildDetailedBadge('Bình thường', 'Bình thường');
    }

    // Sắp xếp mảng warnings theo mã kỳ học tăng dần (cũ đến mới)
    final sortedWarnings = List.from(student.warnings)
      ..sort((a, b) => a.semesterCode.compareTo(b.semesterCode));

    int canhBaoCount = 0;
    List<Widget> badges = [];

    for (var w in sortedWarnings) {
      String label = '';
      String baseStatus = '';

      if (w.warningLevel == 1) {
        canhBaoCount++;
        label = 'Cảnh báo lần $canhBaoCount: ${w.formattedSemester}';
        baseStatus =
            canhBaoCount == 1 ? 'Cảnh báo (Lần 1)' : 'Cảnh báo (Lần 2)';
      } else if (w.warningLevel == 2) {
        label = 'Buộc thôi học: ${w.formattedSemester}';
        baseStatus = 'Buộc thôi học';
      } else if (w.warningLevel == 3) {
        label = 'Ngừng học: ${w.formattedSemester}';
        baseStatus = 'Ngừng học';
      }

      badges.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildDetailedBadge(baseStatus, label),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: badges,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsetsDirectional.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 16.0,
          children: [
            Text(
              student.fullName,
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
                InfoItem(field: "MSSV", value: student.studentCardNumber),
                InfoItem(field: "SĐT", value: student.phoneNumber),
                InfoItem(
                  field: "Email cá nhân",
                  value: "${student.studentCardNumber}@sv1.dut.udn.vn",
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Trạng thái: ',
                          style: TextStyle(
                            fontSize: FontSizes.medium,
                            color: context.theme.grey,
                            height: 1.5,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child:
                            _buildStatusList(), // Gọi hàm tạo danh sách Badge
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(color: context.theme.primaryColor ?? Colors.blue),
            Text(
              'Thông tin liên hệ',
              style: TextStyle(
                fontSize: FontSizes.extraLarge,
                fontWeight: FontWeight.w900,
                color: context.theme.primaryColor ?? Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
