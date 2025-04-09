import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/schedule/presentation/widgets/cards/absents_card.dart';
import 'package:flutter/material.dart';

class StudentItem extends StatelessWidget {
  const StudentItem({
    super.key,
    required this.name,
    required this.mail,
    this.absentCount = -1,
    this.isCheckAbsent = false,
    this.isAbsentToday = false,
    this.onAbsentChanged,
  });

  final String name;
  final String mail;
  final int absentCount;
  final bool isCheckAbsent;
  final bool isAbsentToday;
  final ValueChanged<bool>? onAbsentChanged;

  void _toggleAbsent() {
    if (onAbsentChanged != null) {
      onAbsentChanged!(!isAbsentToday);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromRGBO(116, 116, 116, 1),
            width: 0.5,
          ), // Chỉ border bottom
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://www.udn.vn/Portals/0/3doan%20bk.jpg',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error,
                            size: 40, color: Colors.red); // Hiển thị icon lỗi
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: FontSizes.medium,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true, // Cho phép xuống hàng
                        overflow: TextOverflow.visible, // Không cắt chữ
                      ),
                      Text(
                        mail,
                        style: TextStyle(
                          fontSize: FontSizes.small,
                        ),
                        softWrap: true, // Cho phép xuống hàng
                        overflow: TextOverflow.visible, // Không cắt chữ
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (absentCount != -1)
            if (!isCheckAbsent)
              // ignore: dead_code
              Container(
                width: 39,
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AbsentsCard(
                          isTeacher: true,
                          name: name.toString(),
                          mail: mail.toString(),
                          absentDates: ["10/09/2023", "11/09/2023"]),
                    );
                  },
                  child: Text(
                    "$absentCount",
                    style: TextStyle(
                      fontSize: FontSizes.medium,
                      color: absentCount > 0
                          ? context.theme.red
                          : context.theme.grey,
                      decoration: TextDecoration.underline,
                      decorationColor: absentCount > 0
                          ? context.theme.red
                          : context.theme.grey,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 83,
                alignment: Alignment.center,
                child: Checkbox(
                  value: isAbsentToday,
                  activeColor: context.theme.primaryColor,
                  onChanged: (bool? newValue) {
                    _toggleAbsent();
                  },
                ),
              )
        ],
      ),
    );
  }
}
