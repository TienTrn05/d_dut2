import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarMonth extends StatelessWidget {
  const CalendarMonth({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCalendar();
  }
}

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({super.key});

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25), // Màu bóng
              blurRadius: 12, // Độ mờ của bóng
              spreadRadius: 0, // Độ lan của bóng
              offset: const Offset(0, 4), // Vị trí bóng (x, y)
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        _focusedDay = DateTime(_focusedDay.year,
                            _focusedDay.month - 1, _focusedDay.day);
                      });
                    },
                    child: Icon(Icons.arrow_back_ios_new_rounded)),
                Text(
                  'Tháng ${_focusedDay.month}, ${_focusedDay.year}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.theme.primaryColor ?? Colors.blue,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(_focusedDay.year,
                            _focusedDay.month + 1, _focusedDay.day);
                      });
                    },
                    icon: Icon(Icons.arrow_forward_ios_rounded)),
              ],
            ),
            SizedBox(
              height: 18,
            ),
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              headerVisible: false,
              daysOfWeekVisible: true,
              daysOfWeekHeight: 30,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                weekendStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: Colors.black),
                selectedDecoration: BoxDecoration(
                  color: context.theme.lightBlue ?? Colors.blue.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.black),
                markersMaxCount: 2, // Số lượng điểm tối đa hiển thị
                markersAlignment: Alignment.bottomCenter,
                markersOffset: PositionedOffset(bottom: 4),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              startingDayOfWeek: StartingDayOfWeek.monday,
            ),
          ],
        ));
  }
}
