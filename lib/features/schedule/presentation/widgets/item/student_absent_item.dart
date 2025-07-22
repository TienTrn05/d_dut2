import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';

class StudentAbsentItem extends StatelessWidget {
  const StudentAbsentItem({
    super.key,
    required this.name,
    required this.mail,
    this.isAbsentToday = false,
    this.onAbsentChanged,
  });

  final String name;
  final String mail;
  final bool isAbsentToday;
  final ValueChanged<bool>? onAbsentChanged;

  void _toggleAbsent() {
    if (onAbsentChanged != null) {
      onAbsentChanged!(!isAbsentToday);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _toggleAbsent(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isAbsentToday ? context.theme.lightBlue : Colors.white,
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
                    width: 48,
                    alignment: Alignment.center,
                    child: Checkbox(
                      value: isAbsentToday,
                      activeColor: context.theme.primaryColor,
                      onChanged: (bool? newValue) {
                        _toggleAbsent();
                      },
                    ),
                  ),
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
          ],
        ),
      ),
    );
  }
}
