import 'package:flutter/material.dart';

import '../../../../common/extensions/custom_theme_extension.dart';

class ScheduleItem extends StatelessWidget {
  final String subject;
  final String time;
  final String room;
  final bool isExam;

  const ScheduleItem(
      {super.key,
      required this.subject,
      required this.time,
      required this.room,
      this.isExam = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Color.fromRGBO(245, 245, 245, 1),
        border: Border(
          left: BorderSide(
            color: isExam
                ? (context.theme.red ?? Colors.red)
                : (context.theme.primaryColor ?? Colors.blue),
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1),
          ),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  room,
                  style: TextStyle(
                    color: Color.fromRGBO(116, 116, 116, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
