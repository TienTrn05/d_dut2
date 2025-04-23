import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/schedule/bloc/schedule/calendar_bloc.dart';
import 'package:e_dut/features/schedule/bloc/schedule/schedule_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

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
  Map<DateTime, List<int>> _eventMap = {};
  CalendarFormat _calendarFormat =
      CalendarFormat.month; // Lịch mặc định là tháng

  void _loadCalendarEventsForMonth() {
    context.read<CalendarBloc>().add(
          LoadCalendarEvents(
            month: _focusedDay.month,
            year: _focusedDay.year,
          ),
        );
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(); // Khởi tạo locale để tránh lỗi

    _loadCalendarEventsForMonth();

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

  // Hàm để chọn tháng và năm
  Future<void> _selectMonthYear() async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: _selectedDay ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      monthPickerDialogSettings: MonthPickerDialogSettings(
          headerSettings: PickerHeaderSettings(
              headerBackgroundColor: context.theme.primaryColor),
          dialogSettings: PickerDialogSettings(
            locale: Locale('vi'),
            dialogRoundedCornersRadius: 16,
            dialogBackgroundColor: Colors.white,
          ),
          dateButtonsSettings: PickerDateButtonsSettings(
            selectedMonthBackgroundColor: context.theme.primaryColor,
            selectedMonthTextColor: Colors.white,
            unselectedMonthsTextColor: Colors.black,
            currentMonthTextColor: context.theme.primaryColor,
          ),
          actionBarSettings: PickerActionBarSettings(
            // cancelWidget: Padding(
            //   padding: const EdgeInsets.only(bottom: 16),
            //   child: ElevatedButton(
            //     onPressed: () => Navigator.of(context).pop(),
            //     style: ElevatedButton.styleFrom(
            //       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //       backgroundColor: Colors.white,
            //     ),
            //     child: Text(
            //       "Hủy",
            //       style: TextStyle(
            //         color: context.theme.primaryColor,
            //       ),
            //     ),
            //   ),
            // ),
            // confirmWidget: Padding(
            //   padding: const EdgeInsets.only(bottom: 16),
            //   child: ElevatedButton(
            //     onPressed: () => Navigator.of(context).pop(),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: context.theme.primaryColor ?? Colors.blue,
            //       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //     ),
            //     child: Text(
            //       "Chọn",
            //       style: TextStyle(
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
          ),),
    );

    if (picked != null) {
      setState(() {
        _focusedDay = picked;
      });
      context.read<CalendarBloc>().add(
            LoadCalendarEvents(
              month: _focusedDay.month,
              year: _focusedDay.year,
            ),
          );
    }
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
          BlocListener<CalendarBloc, CalendarState>(listener: (context, state) {
            if (state is CalendarEventLoaded) {
              final newEventMap = <DateTime, List<int>>{};
              for (var event in state.calendarEvents) {
                final date =
                    DateTime(event.date.year, event.date.month, event.date.day);
                newEventMap.putIfAbsent(date, () => []);
                newEventMap[date]!
                    .addAll(event.eventTypes.map((e) => e.eventType));
              }

              setState(() {
                _eventMap = newEventMap;
              });
            }
          }, child: BlocBuilder<CalendarBloc, CalendarState>(
              builder: (context, state) {
            if (state is CalendarEventLoaded) {
              _eventMap = {};
              for (var event in state.calendarEvents) {
                final date =
                    DateTime(event.date.year, event.date.month, event.date.day);
                if (!_eventMap.containsKey(date)) {
                  _eventMap[date] = [];
                }
                for (var eventType in event.eventTypes) {
                  _eventMap[date]!.add(eventType.eventType);
                }
              }
            }

            return GestureDetector(
              onTap: _selectMonthYear,
              child: TableCalendar(
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
                  context.read<CalendarBloc>().add(
                        LoadCalendarEvents(
                          month: focusDate.month,
                          year: focusDate.year,
                        ),
                      );
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
                  return isSameDay(
                      _selectedDay, day); // Kiểm tra ngày được chọn
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay; // Cập nhật ngày được chọn
                    _focusedDay = selectedDay; // Cập nhật tiêu đề tháng
                  });
                  context
                      .read<ScheduleBloc>()
                      .add(LoadSchedulesByDate(inputDate: _selectedDay));
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
                    color: Color.fromRGBO(
                        245, 245, 245, 1), // Màu nền ngày hôm nay
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
                    final text =
                        day.weekday == 7 ? "CN" : 'T${day.weekday + 1}';
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
                  markerBuilder: (context, date, _) {
                    final normalizedDate =
                        DateTime(date.year, date.month, date.day);
                    if (_eventMap.containsKey(normalizedDate)) {
                      List<int> eventTypes = _eventMap[normalizedDate]!;
                      return Positioned(
                        bottom: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: eventTypes.take(2).map((type) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: type == 1 // Học
                                      ? Color.fromRGBO(42, 116, 189, 1)
                                      : Color.fromRGBO(204, 1, 2, 1)),
                            );
                          }).toList(),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            );
          })),
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
                _calendarFormat == CalendarFormat.month
                    ? "- Thu gọn -"
                    : "- Tuần ${_currentWeek.toString()} -",
                style: TextStyle(color: Color.fromRGBO(116, 116, 116, 1)),
              ))
        ],
      ),
    );
  }
}
