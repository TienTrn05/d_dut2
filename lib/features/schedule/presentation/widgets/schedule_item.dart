import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:flutter/material.dart';

class ScheduleItem extends StatelessWidget {
  final String idSubject;
  final String subject;
  final String time;
  final String room;
  final bool isExam;

  const ScheduleItem({
    super.key,
    required this.idSubject,
    required this.subject,
    required this.time,
    required this.room,
    this.isExam = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context)
            .pushNamed(Routes.detail_unit_of_study, arguments: idSubject)
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 4),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Color.fromRGBO(245, 245, 245, 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Container(
              padding: EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                border: Border(
                    left: BorderSide(
                  color: isExam
                      ? (context.theme.red ?? Colors.red)
                      : (context.theme.primaryColor ?? Colors.blue),
                  width: 4,
                )),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        room,
                        style: TextStyle(
                          color: Color.fromRGBO(116, 116, 116, 1),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
