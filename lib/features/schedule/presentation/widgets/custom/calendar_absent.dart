import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarAbsent extends StatefulWidget {
  const CalendarAbsent(
      {super.key, required this.initDate, required this.onValueChange});
  final DateTime initDate;
  final Function(DateTime) onValueChange;

  @override
  State<CalendarAbsent> createState() => _CalendarAbsentState();
}

class _CalendarAbsentState extends State<CalendarAbsent> {
  late DateTime _focusedDay; // Tháng hiện tại đang xem
  late DateTime _selectedDay; // Lưu ngày được chọn

  List<DateTime> events = [
    DateTime.utc(2025, 3, 10),
    DateTime.utc(2025, 3, 15),
    DateTime.utc(2025, 3, 20),
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(); // Khởi tạo locale để tránh lỗi
    _focusedDay = widget.initDate;
    _selectedDay = widget.initDate;
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(64), // Màu của shadow
              spreadRadius: 0, // Độ lan của shadow
              blurRadius: 12, // Độ mờ của shadow
              offset: Offset(0, 4), // Độ lệch (X, Y)
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TableCalendar(
              locale: 'vi',
              focusedDay: _focusedDay,
              onPageChanged: (focusDate) {
                setState(() {
                  _focusedDay = focusDate;
                });
              },
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              availableCalendarFormats: {
                CalendarFormat.month: 'Month',
                CalendarFormat.week: 'Week',
              },
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day); // Kiểm tra ngày được chọn
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  widget.onValueChange(selectedDay);
                });
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(42, 116, 189, 1),
                  fontSize: FontSizes.medium,
                ),
                titleTextFormatter: (date, locale) {
                  String monthNumber =
                      DateFormat.M(locale).format(date); // Lấy số tháng
                  String formatted = "Tháng $monthNumber, ${date.year}";

                  return formatted;
                },
                formatButtonVisible: false,
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: FontSizes.small),
                weekendStyle: TextStyle(fontSize: FontSizes.small),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(fontSize: FontSizes.medium),
                weekendTextStyle: TextStyle(fontSize: FontSizes.medium),
                outsideTextStyle: TextStyle(
                    fontSize: FontSizes.small, color: context.theme.grey),
                cellMargin: EdgeInsets.all(0),
                todayDecoration: BoxDecoration(
                  color:
                      Color.fromRGBO(245, 245, 245, 1), // Màu nền ngày hôm nay
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                    color: Colors.black, // Màu chữ của ngày hôm nay
                    fontWeight: FontWeight.bold,
                    fontSize: FontSizes.small),
                selectedDecoration: BoxDecoration(
                  color: Color.fromRGBO(
                      203, 221, 235, 1), // Màu nền ngày được chọn
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  final text = day.weekday == 7 ? "CN" : 'T${day.weekday + 1}';
                  return Center(
                    child: Text(
                      text,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1),
                    ),
                  );
                },
                markerBuilder: (context, date, eventsList) {
                  bool hasEvent =
                      events.any((eventDate) => isSameDay(eventDate, date));
                  if (hasEvent) {
                    return Positioned(
                      bottom: 12,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(42, 116, 189, 1),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            Divider(color: context.theme.primaryColor ?? Colors.blue),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Nhật ký điểm danh',
              style: TextStyle(
                  fontSize: FontSizes.extraLarge,
                  fontWeight: FontWeight.bold,
                  color: context.theme.primaryColor ?? Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
