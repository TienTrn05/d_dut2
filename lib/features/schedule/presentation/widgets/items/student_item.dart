import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/schedule/presentation/widgets/cards/absents_card.dart';
import 'package:flutter/material.dart';

class StudentItem extends StatefulWidget {
  StudentItem({
    super.key,
    required this.name,
    required this.mail,
    this.absentCount,
    this.isCheckAbsent = false,
    this.isAbsentToday = false,
  });

  final String name;
  final String mail;
  final absentCount;
  bool isCheckAbsent;
  bool isAbsentToday;

  @override
  State<StudentItem> createState() => _StudentItemState();
}

class _StudentItemState extends State<StudentItem> {
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
                        widget.name,
                        style: TextStyle(
                          fontSize: FontSizes.medium,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true, // Cho phép xuống hàng
                        overflow: TextOverflow.visible, // Không cắt chữ
                      ),
                      Text(
                        widget.mail,
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
          if (widget.absentCount != null)
            if (!widget.isCheckAbsent)
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
                          name: widget.name.toString(),
                          mail: widget.mail.toString(),
                          absentDates: ["10/09/2023", "11/09/2023"]),
                    );
                  },
                  child: Text(
                    "${widget.absentCount}",
                    style: TextStyle(
                      fontSize: FontSizes.medium,
                      color: widget.absentCount % 2 == 0
                          ? context.theme.red
                          : context.theme.grey,
                      decoration: TextDecoration.underline,
                      decorationColor: widget.absentCount % 2 == 0
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
                  value: widget.isAbsentToday,
                  activeColor: context.theme.primaryColor,
                  onChanged: (bool? newValue) {
                    setState(() {
                      widget.isAbsentToday = !widget.isAbsentToday;
                    });
                  },
                ),
              )
        ],
      ),
    );
  }
}
