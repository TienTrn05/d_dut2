import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({
    super.key,
    required this.onValueChange,
    this.initDate,
    this.minSelectableDate,
  });

  final DateTime? initDate;
  final Function(DateTime) onValueChange;
  final DateTime? minSelectableDate;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  final List<DateTime> events = [
    DateTime.utc(2025, 3, 10),
    DateTime.utc(2025, 3, 15),
    DateTime.utc(2025, 3, 20),
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _focusedDay = widget.initDate ?? DateTime.now();
    _selectedDay = widget.initDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(64),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TableCalendar(
              locale: 'vi',
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2010, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) =>
                  _selectedDay != null && isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                widget.onValueChange(selectedDay);
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              enabledDayPredicate: (day) {
                if (widget.minSelectableDate == null) return true;
                return !day.isBefore(widget.minSelectableDate!);
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(42, 116, 189, 1),
                  fontSize: FontSizes.medium,
                ),
                titleTextFormatter: (date, locale) {
                  final month = DateFormat.M(locale).format(date);
                  return 'Tháng $month, ${date.year}';
                },
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: FontSizes.small),
                weekendStyle: TextStyle(fontSize: FontSizes.small),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(fontSize: FontSizes.medium),
                weekendTextStyle: const TextStyle(fontSize: FontSizes.medium),
                outsideTextStyle: TextStyle(
                  fontSize: FontSizes.small,
                  color: context.theme.grey,
                ),
                cellMargin: EdgeInsets.zero,
                todayDecoration: const BoxDecoration(
                  color: Color.fromRGBO(245, 245, 245, 1),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: FontSizes.small,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color.fromRGBO(203, 221, 235, 1),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                disabledTextStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: FontSizes.medium,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  final text = day.weekday == 7 ? "CN" : 'T${day.weekday + 1}';
                  return Center(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1,
                      ),
                    ),
                  );
                },
                markerBuilder: (context, date, eventsList) {
                  final hasEvent = events.any((e) => isSameDay(e, date));
                  if (hasEvent) {
                    return Positioned(
                      bottom: 12,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
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
          ],
        ),
      ),
    );
  }
}
