import 'package:e_dut/features/schedule/presentation/widgets/calendar_month.dart';
import 'package:e_dut/features/schedule/presentation/widgets/selection_button.dart';
import 'package:e_dut/features/schedule/presentation/widgets/subject_item.dart';
import 'package:flutter/material.dart';

class DayView extends StatelessWidget {
  const DayView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalendarCustom(),
          SizedBox(height: 20),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                'Tuần 32, 22/01/2025',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              SelectionButton(),
            ],
          ),
          SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubjectItem(
                subject: 'Điện toán đám mây',
                time: '7:00 - 9:50',
                room: 'F109',
              ),
              const SizedBox(height: 4),
              SubjectItem(
                subject: 'Lập trình di động',
                time: '7:00, xuất 2C1, nhóm A',
                room: 'F109',
                isExam: true,
              ),
              const SizedBox(height: 4),
              SubjectItem(
                subject: 'Đồ án 1',
                time: '13:00 - 15:50',
                room: 'F109',
              ),
              const SizedBox(height: 4),
              SubjectItem(
                subject: 'Đồ án 1',
                time: '13:00 - 15:50',
                room: 'F109',
              ),
              const SizedBox(height: 4),
              SubjectItem(
                subject: 'Đồ án 1',
                time: '13:00 - 15:50',
                room: 'F109',
              ),
            ],
          )
        ],
      ),
    );
  }
}
