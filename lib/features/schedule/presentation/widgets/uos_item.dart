import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/routes/routes.dart';
import 'package:flutter/material.dart';

class DetailUnitOfStudyItem extends StatelessWidget {
  final String idSubject;
  final String nameSubject;
  final bool isExam;
  final int? credit;
  final String? weekRange;
  final String? time;
  final String? room;
  final String? teacher;

  final String? examShiftNo;
  final String? examGroupNo;

  const DetailUnitOfStudyItem(
      {super.key,
      required this.idSubject,
      required this.nameSubject,
      this.isExam = false,
      this.credit,
      this.weekRange,
      this.time,
      this.room,
      this.teacher,
      this.examShiftNo,
      this.examGroupNo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context)
            .pushNamed(Routes.detailUnitOfStudy, arguments: idSubject)
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Color.fromRGBO(245, 245, 245, 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  idSubject,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: context.theme.grey ?? Colors.grey),
                ),
                Text(
                  credit != null ? '$credit tín chỉ' : '',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: context.theme.grey ?? Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              nameSubject,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.25,
                color: isExam
                    ? context.theme.red ?? Colors.red
                    : context.theme.primaryColor ?? Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (time != null || room != null)
                  ? '$time, $room'
                  : 'Hiện chưa có lịch',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: (time != null || room != null)
                    ? Colors.black
                    : context.theme.grey ?? Colors.grey,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            weekRange != null && weekRange!.isNotEmpty
                ? Text(
                    'Tuần $weekRange',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: context.theme.grey ?? Colors.grey,
                    ),
                  )
                : SizedBox.shrink(),
            const SizedBox(height: 4),
            (isExam && examShiftNo != null && examGroupNo != null) ||
                    (!isExam && teacher != null)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        isExam
                            ? 'Xuất $examShiftNo, nhóm $examGroupNo'
                            : 'GV: $teacher',
                        style: TextStyle(
                          color: context.theme.grey ?? Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          height: 1.25,
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
