import 'dart:async';

import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/widgets/dialog/custom_alert_dialog.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:e_dut/features/schedule/bloc/schedule/calendar_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  Map<DateTime, List<int>> _eventMap = {};

  List<DateTime> events = [];
  Timer? _debounce;

  void _loadCalendarEventsForMonth() {
    final authState = context.read<AuthBloc>().state;

    final String userRole =
        authState is AuthUserAuthenticated ? authState.userData.role.name : '';
    context.read<CalendarBloc>().add(
          LoadCalendarEvents(
              month: widget.initDate.month,
              year: widget.initDate.year,
              isTeacher: userRole == RoleModel.roleTeacher),
        );
  }

  void _warningNotAbsentDate() {
    CustomAlertDialog.showCustomDialog(
        context,
        'Bạn không có tiết ngày này.',
        'Vui lòng chọn ngày bạn có tiết dạy để thực hiện điểm danh.',
        AlertType.warning,
        textCancel: "Đóng");
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(); // Khởi tạo locale để tránh lỗi
    _focusedDay = widget.initDate;
    _selectedDay = widget.initDate;
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

  bool isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
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
            BlocListener<CalendarBloc, CalendarState>(
                // Lắng nghe khi state thay đổi để thực hiện hành động phụ
                listener: (context, state) {
              if (state is CalendarEventLoaded) {
                final newEventMap = <DateTime, List<int>>{};
                for (var event in state.calendarEvents) {
                  final date = DateTime(
                      event.date.year, event.date.month, event.date.day);
                  newEventMap.putIfAbsent(date, () => []);
                  newEventMap[date]!.addAll(event.eventTypes
                      .where((e) => e.eventType == 3)
                      .map((e) => e.eventType));
                }

                setState(() {
                  _eventMap = newEventMap;
                });
              }
            }, child: BlocBuilder<CalendarBloc, CalendarState>(
                    // Dùng state để build lại giao diện
                    builder: (context, state) {
              if (state is CalendarLoading) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 82),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.theme.primaryColor,
                    ),
                  ),
                );
              }
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
                  if (_debounce?.isActive ?? false) _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 800), () {
                    context.read<CalendarBloc>().add(
                          LoadCalendarEvents(
                              month: focusDate.month,
                              year: focusDate.year,
                              isTeacher: userRole == RoleModel.roleTeacher),
                        );
                  });
                },
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                availableCalendarFormats: {
                  CalendarFormat.month: 'Month',
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) {
                  return isSameDay(
                      _selectedDay, day); // Kiểm tra ngày được chọn
                },
                onDaySelected: (selectedDay, focusedDay) {
                  bool isAbsentDate = _eventMap.keys
                      .any((date) => isSameDate(date, selectedDay));
                  if (!isAbsentDate) {
                    _warningNotAbsentDate();
                  } else {
                    setState(() {
                      widget.onValueChange(selectedDay);
                    });
                  }
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
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
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
                          ),
                        ),
                      ),
                    );
                  },
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
                          children: eventTypes.take(1).map((type) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(42, 116, 189, 1),
                              ),
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
            Divider(color: context.theme.primaryColor ?? Colors.blue),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Lịch dạy',
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
