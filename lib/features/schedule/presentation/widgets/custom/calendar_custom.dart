import 'dart:async';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/schedule/bloc/schedule/calendar_bloc.dart';
import 'package:e_dut/features/schedule/bloc/schedule/schedule_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late String _currentWeek = "Lỗi";
  Map<DateTime, List<int>> _eventMap = {};
  CalendarFormat _calendarFormat =
      CalendarFormat.month; // Lịch mặc định là tháng
  Timer? _debounce;

  void _loadCalendarEventsForMonth() {
    final authState = context.read<AuthBloc>().state;

    final String userRole =
        authState is AuthUserAuthenticated ? authState.userData.role.name : '';
    final String authToken =
        authState is AuthUserAuthenticated ? authState.accessToken : '';
    context.read<CalendarBloc>().add(
          LoadCalendarEvents(
              month: _focusedDay.month,
              year: _focusedDay.year,
              isTeacher: userRole == RoleModel.roleTeacher,
              authToken: authToken),
        );
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(); // Khởi tạo locale để tránh lỗi
    _loadCalendarEventsForMonth();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showMonthYearPicker() {
    int tempMonth = _focusedDay.month;
    int tempYear = _focusedDay.year;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            height: 250,
            child: Row(
              children: [
                // Tháng
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController:
                        FixedExtentScrollController(initialItem: tempMonth - 1),
                    onSelectedItemChanged: (index) {
                      tempMonth = index + 1;
                      setState(() {
                        _focusedDay = DateTime(tempYear, tempMonth, 1);
                      });
                    },
                    selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                      background: Colors.lightBlue.withAlpha(30),
                    ),
                    children: List.generate(
                      12,
                      (index) {
                        return Center(
                          child: Center(
                            child: Text("${index + 1}"),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Năm
                Expanded(
                  child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                          initialItem: tempYear - 2000),
                      onSelectedItemChanged: (index) {
                        tempYear = index + 2000;
                        setState(() {
                          _focusedDay = DateTime(tempYear, tempMonth, 1);
                        });
                      },
                      selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                        background: Colors.lightBlue.withAlpha(30),
                      ),
                      children: List.generate(
                        50,
                        (index) {
                          return Center(
                            child: Center(
                              child: Text("${index + 2000}"),
                            ),
                          );
                        },
                      )),
                ),
                // Button
              ],
            ),
          ),
        );
      },
    );
  }

  DateTime getMondayOfWeek(DateTime focusedDay) {
    int difference = focusedDay.weekday - DateTime.monday;
    return focusedDay.subtract(Duration(days: difference));
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
            color: Colors.black.withAlpha(64), // Màu của shadow
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
            if (state is CalendarWeekLoaded) {
              setState(() {
                if (state.noWeek.isNotEmpty) {
                  _currentWeek = "Tuần ${state.noWeek}";
                } else {
                  _currentWeek = "Không phải tuần học";
                }
              });
            }
          }, child: BlocBuilder<CalendarBloc, CalendarState>(
              builder: (context, state) {
            return TableCalendar(
              locale: 'vi',
              focusedDay: _focusedDay,
              onPageChanged: (focusDate) {
                setState(() {
                  _focusedDay = focusDate;
                });
                final authState = context.read<AuthBloc>().state;

                final String userRole = authState is AuthUserAuthenticated
                    ? authState.userData.role.name
                    : '';
                final String authToken = authState is AuthUserAuthenticated
                    ? authState.accessToken
                    : '';
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 800), () {
                  context.read<CalendarBloc>().add(
                        LoadCalendarEvents(
                            month: focusDate.month,
                            year: focusDate.year,
                            isTeacher: userRole == RoleModel.roleTeacher,
                            authToken: authToken),
                      );
                  if (_calendarFormat == CalendarFormat.week) {
                    context.read<CalendarBloc>().add(
                          LoadCalendarWeek(
                              inputDate: getMondayOfWeek(_focusedDay),
                              authToken: authToken),
                        );
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
                final authState = context.read<AuthBloc>().state;

                final String userRole = authState is AuthUserAuthenticated
                    ? authState.userData.role.name
                    : '';

                final String authToken = authState is AuthUserAuthenticated
                    ? authState.accessToken
                    : '';
                context.read<ScheduleBloc>().add(LoadSchedulesByDate(
                    inputDate: _selectedDay,
                    isTeacher: userRole == RoleModel.roleTeacher,
                    authToken: authToken));
              },
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
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: context.theme.grey, // đổi màu nút trái
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: context.theme.grey, // đổi màu nút phải
                ),
              ),
              calendarBuilders: CalendarBuilders(
                headerTitleBuilder: (context, date) {
                  String monthNumber = DateFormat.M('vi').format(date);
                  String formatted = "Tháng $monthNumber, ${date.year}";
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showMonthYearPicker,
                      child: Center(
                        child: Text(
                          formatted,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(42, 116, 189, 1),
                            fontSize: FontSizes.medium,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
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
                                // 1: Study, 2: Exam, Teaching: 3
                                color: (type == 1 || type == 3)
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
                });
                if (_calendarFormat == CalendarFormat.week) {
                  final authState = context.read<AuthBloc>().state;
                  final String authToken = authState is AuthUserAuthenticated
                      ? authState.accessToken
                      : '';
                  context.read<CalendarBloc>().add(
                        LoadCalendarWeek(
                            inputDate: getMondayOfWeek(_focusedDay),
                            authToken: authToken),
                      );
                }
              },
              child: Text(
                _calendarFormat == CalendarFormat.month
                    ? "- Thu gọn -"
                    : "- $_currentWeek -",
                style: TextStyle(color: Color.fromRGBO(116, 116, 116, 1)),
              ))
        ],
      ),
    );
  }
}
