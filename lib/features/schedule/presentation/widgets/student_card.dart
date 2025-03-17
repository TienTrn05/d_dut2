import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';

class StudentCard extends StatefulWidget {
  StudentCard({
    super.key,
    required this.name,
    required this.mail,
    this.absentCount,
    this.isCheckAbsent = false,
    this.isAbsentToday = false,
  });

  final name;
  final mail;
  final absentCount;
  bool isCheckAbsent;
  bool isAbsentToday;

  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
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
          Row(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.name}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${widget.mail}",
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!widget.isCheckAbsent)
            // ignore: dead_code
            Container(
              width: 39,
              alignment: Alignment.center,
              child: Text(
                "${widget.absentCount}",
                style: TextStyle(
                  fontSize: 16,
                  color: widget.absentCount % 2 == 0
                      ? context.theme.red
                      : context.theme.grey,
                  decoration: TextDecoration.underline,
                  decorationColor: widget.absentCount % 2 == 0
                      ? context.theme.red
                      : context.theme.grey,
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
