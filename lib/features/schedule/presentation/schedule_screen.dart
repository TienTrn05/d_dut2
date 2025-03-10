import 'package:e_dut/features/schedule/presentation/widgets/calendar_month.dart';
import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [CalendarCustom()],
      ),
    ));
  }
}
