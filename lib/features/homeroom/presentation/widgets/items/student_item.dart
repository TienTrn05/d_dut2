import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/homeroom/data/model/student_model.dart';
import 'package:e_dut/features/homeroom/presentation/widgets/dialog/student_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

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

  Widget _buildStatusBadge(String? status) {
    final String safeStatus = status ?? 'Bình thường';
    Color color;
    IconData icon;
    double iconSize = 12.0;

    switch (safeStatus) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color, width: 0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color), // Sử dụng biến iconSize
          const SizedBox(width: 4),
          Text(
            safeStatus,
            style: TextStyle(
              fontSize: FontSizes.small,
              color: color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isInactive =
        student.computedStatus == 'Ngừng học' ||
        student.computedStatus == 'Buộc thôi học';

    final Color nameColor = isInactive ? const Color(0XFF606166) : Colors.black;
    final Color idColor =
        isInactive ? const Color(0XFF606166).withOpacity(0.8) : Colors.black87;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (builder, authState) {
        final userRole =
            authState is AuthUserAuthenticated
                ? authState.userData.role.name
                : '';
        return GestureDetector(
          onTap: () {
            userRole == RoleModel.roleTeacher
                ? showDialog(
                  context: context,
                  builder:
                      (dialogContext) => StudentInfoDialog(student: student),
                )
                : null;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromRGBO(116, 116, 116, 1),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: const TextStyle(
                          fontSize: FontSizes.medium,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userRole == RoleModel.roleStudent
                            ? maskCode(student.studentCardNumber)
                            : student.studentCardNumber,
                        style: const TextStyle(
                          fontSize: FontSizes.small,
                          color: Colors.black87,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),

                if (userRole == RoleModel.roleTeacher)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    // TRUYỀN computedStatus VÀO BADGE
                    child: _buildStatusBadge(student.computedStatus),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
