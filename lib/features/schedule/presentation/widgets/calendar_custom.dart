import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarCustom extends StatefulWidget {
  const CalendarCustom({super.key});

  @override
  State<CalendarCustom> createState() => _CalendarCustomState();
}

class _CalendarCustomState extends State<CalendarCustom> {
  DateTime _focusedDay = DateTime.now(); // Tháng hiện tại đang xem
  DateTime _selectedDay = DateTime.now(); // Lưu ngày được chọn
  final DateTime _startdWeek = DateTime(2025, 3, 3);
  int? _currentWeek;

  Map<DateTime, List<String>> events = {
    DateTime.utc(2025, 3, 10): ["học", "thi"],
    DateTime.utc(2025, 3, 15): ["thi"],
    DateTime.utc(2025, 3, 20): ["học"],
  };
  CalendarFormat _calendarFormat =
      CalendarFormat.month; // Lịch mặc định là tháng

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(); // Khởi tạo locale để tránh lỗi

    if (_focusedDay.isAfter(_startdWeek)) {
      int weekDifference = _focusedDay.difference(_startdWeek).inDays ~/ 7;
      _currentWeek = weekDifference + 1;
    } else {
      _currentWeek = 0;
    }
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // Màu của shadow
            spreadRadius: 0, // Độ lan của shadow
            blurRadius: 12, // Độ mờ của shadow
            offset: Offset(0, 4), // Độ lệch (X, Y)
          ),
        ],
      ),
      child: Column(
        children: [
          TableCalendar(
            locale: 'vi',
            focusedDay: _focusedDay,
            onPageChanged: (focusDate) {
              setState(() {
                _focusedDay = focusDate;
                if (focusDate.isAfter(_startdWeek)) {
                  int weekDifference =
                      _focusedDay.difference(_startdWeek).inDays ~/ 7;
                  _currentWeek = weekDifference + 1;
                } else {
                  _currentWeek = 0;
                }
              });
            },
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            availableCalendarFormats: {
              CalendarFormat.month: 'Month',
              CalendarFormat.week: 'Week',
            },
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day); // Kiểm tra ngày được chọn
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay; // Cập nhật ngày được chọn
                _focusedDay = selectedDay; // Cập nhật tiêu đề tháng
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
              outsideTextStyle: TextStyle(fontSize: FontSizes.small, color: context.theme.grey),
              cellMargin: EdgeInsets.all(0),
              todayDecoration: BoxDecoration(
                color: Color.fromRGBO(245, 245, 245, 1), // Màu nền ngày hôm nay
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                  color: Colors.black, // Màu chữ của ngày hôm nay
                  fontWeight: FontWeight.bold,
                  fontSize: FontSizes.small),
              selectedDecoration: BoxDecoration(
                color:
                    Color.fromRGBO(203, 221, 235, 1), // Màu nền ngày được chọn
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
                if (events.containsKey(date)) {
                  List<String> eventTypes = events[date]!;
                  return Positioned(
                    bottom: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: eventTypes.take(2).map((event) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: event == "học"
                                  ? Color.fromRGBO(42, 116, 189, 1)
                                  : Color.fromRGBO(204, 1, 2, 1)),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ),
          TextButton(
              onPressed: () {
                setState(() {
                  if (_calendarFormat == CalendarFormat.month) {
                    _calendarFormat = CalendarFormat.week;
                    _focusedDay = _selectedDay;
                  } else {
                    _calendarFormat = CalendarFormat.month;
                  }
                  if (_focusedDay.isAfter(_startdWeek)) {
                    int weekDifference =
                        _focusedDay.difference(_startdWeek).inDays ~/ 7;
                    _currentWeek = weekDifference + 1;
                  } else {
                    _currentWeek = 0;
                  }
                });
              },
              child: Text(
                _calendarFormat == CalendarFormat.month ? "- Thu gọn -" :"- Tuần ${ _currentWeek.toString()} -",
                style: TextStyle(color: Color.fromRGBO(116, 116, 116, 1)),
              ))
        ],
      ),
    );
  }
}
