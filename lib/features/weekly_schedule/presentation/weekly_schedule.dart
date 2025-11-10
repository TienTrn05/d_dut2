import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../common/extensions/font_sizes.dart';
import '../../../common/widgets/loading/loading_progress_bar.dart';
import '../../../common/widgets/appbar/custom_appbar.dart';

import '../bloc/weekly_schedule_bloc.dart';
import '../models/weekly_schedule_model.dart';
import 'detail_schedule.dart';

// Lấy tuần theo năm học
import 'package:e_dut/features/schedule/bloc/schedule/calendar_bloc.dart';
import '../../../features/auth/bloc/auth_bloc.dart';

DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

bool _isSameLocalDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _mondayOf(DateTime day) {
  final d = _normalize(day);
  final weekday = d.weekday;
  return d.subtract(Duration(days: weekday - 1));
}

int _isoWeekNumber(DateTime date) {
  final dUtc = DateTime.utc(date.year, date.month, date.day);

  final int weekday = dUtc.weekday;
  final thursday = dUtc.add(Duration(days: (4 - weekday)));
  final yearOfThursday = thursday.year;

  final jan4 = DateTime.utc(yearOfThursday, 1, 4);

  final mondayOfWeek1 = jan4.subtract(Duration(days: jan4.weekday - 1));
  final diffDays = thursday.difference(mondayOfWeek1).inDays;

  final weekNumber = (diffDays ~/ 7) + 1;
  return weekNumber;
}

DateTime _firstDayWithEventOrMonday(
  DateTime anyDayInWeek,
  Map<DateTime, List> events,
) {
  final monday = _mondayOf(anyDayInWeek);
  final mondayNorm = _normalize(monday);

  // Nếu T2 có event => focus T2
  if ((events[mondayNorm] ?? []).isNotEmpty) {
    return mondayNorm;
  }

  // Nếu có event trong tuần => focus ngày đầu tiên có event
  for (int i = 0; i < 7; i++) {
    final day = _normalize(monday.add(Duration(days: i)));
    if ((events[day] ?? []).isNotEmpty) {
      return day;
    }
  }

  // Nếu không có event, nhưng hôm nay nằm trong tuần => focus hôm nay
  final today = _normalize(DateTime.now());
  final weekStart = mondayNorm;
  final weekEnd = _normalize(monday.add(const Duration(days: 6)));
  if (!today.isBefore(weekStart) && !today.isAfter(weekEnd)) {
    return today;
  }

  // Ngược lại trả về T2
  return mondayNorm;
}

Map<DateTime, List<WeeklyScheduleItem>> _eventMap(
  List<WeeklyScheduleItem> items,
) {
  final map = <DateTime, List<WeeklyScheduleItem>>{};
  for (final it in items) {
    final key = _normalize(it.day);
    (map[key] ??= []).add(it);
  }
  return map;
}

class WeeklySchedulePage extends StatefulWidget {
  const WeeklySchedulePage({super.key, required this.email});
  final String email;

  @override
  State<WeeklySchedulePage> createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  String _academicWeekLabel = '';
  Map<DateTime, List<WeeklyScheduleItem>> _cachedEvents = {};
  bool _ignoreNextWeeklyListener = false;

  bool _initialLoadInProgress = true;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _initialLoadInProgress = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<WeeklyScheduleBloc>().add(
        WeeklyScheduleRequested(widget.email),
      );
      _requestAcademicWeek(_focusedDay);
    });
  }

  void _requestAcademicWeek(DateTime anyDayInWeek) {
    final monday = _mondayOf(anyDayInWeek);
    final authState = context.read<AuthBloc>().state;
    final token =
        authState is AuthUserAuthenticated ? authState.accessToken : '';

    try {
      context.read<CalendarBloc>().add(
        LoadCalendarWeek(inputDate: monday, authToken: token),
      );
    } catch (_) {}
  }

  bool _hasEventsOn(
    DateTime day,
    Map<DateTime, List<WeeklyScheduleItem>> events,
  ) {
    final key = _normalize(day);
    final list = events[key];
    return list != null && list.isNotEmpty;
  }

  List<WeeklyScheduleItem> _itemsOfSelectedDayFromCache() {
    final list = _cachedEvents[_normalize(_selectedDay)];
    if (list == null) return [];
    final copy = List<WeeklyScheduleItem>.from(list);
    copy.sort((a, b) => a.start.compareTo(b.start));
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,

      // Header + thanh loading mảnh
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomAppbar(label: 'Lịch tuần'),
            BlocBuilder<WeeklyScheduleBloc, WeeklyScheduleState>(
              buildWhen:
                  (p, c) =>
                      p.isLoading != c.isLoading ||
                      (p.data == null) != (c.data == null),
              builder: (context, state) {
                final showLoading =
                    state.isLoading &&
                    state.data == null &&
                    _initialLoadInProgress;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child:
                      showLoading
                          ? SizedBox(
                            key: const ValueKey('weekly-loading'),
                            height: 2,
                            width: double.infinity,
                            child: CustomLoadingIndicator.thin(),
                          )
                          : const SizedBox(
                            key: ValueKey('weekly-not-loading'),
                            height: 2,
                          ),
                );
              },
            ),
          ],
        ),
      ),

      body: BlocListener<CalendarBloc, CalendarState>(
        listenWhen: (prev, curr) => curr is CalendarWeekLoaded,
        listener: (context, state) {
          if (state is CalendarWeekLoaded) {
            setState(() {
              _academicWeekLabel =
                  state.noWeek.isNotEmpty ? 'Tuần ${state.noWeek}' : '';
            });
          }
        },
        child: BlocListener<WeeklyScheduleBloc, WeeklyScheduleState>(
          listenWhen:
              (prev, curr) => prev.data != curr.data && curr.data != null,
          listener: (context, state) {
            if (mounted && _initialLoadInProgress) {
              setState(() {
                _initialLoadInProgress = false;
              });
            }

            if (state.data != null) {
              _cachedEvents = _eventMap(state.data!.schedules);
            }

            if (_ignoreNextWeeklyListener) {
              _ignoreNextWeeklyListener = false;
              print(
                '[weekly_listener] skipped clobber due to user tap. selected=$_selectedDay focused=$_focusedDay',
              );
              return;
            }

            final data = state.data!;
            final events = _eventMap(data.schedules);

            final weekStart = _mondayOf(_normalize(_focusedDay));
            final weekEnd = _normalize(weekStart.add(const Duration(days: 6)));

            final selectedIsInWeek =
                !_selectedDay.isBefore(weekStart) &&
                !_selectedDay.isAfter(weekEnd);
            final selectedHasEvent = _hasEventsOn(_selectedDay, events);

            if (!selectedIsInWeek || !selectedHasEvent) {
              final newSelected = _firstDayWithEventOrMonday(
                _normalize(_focusedDay),
                events,
              );

              if (mounted) {
                setState(() {
                  _selectedDay = _normalize(newSelected);
                  _focusedDay = _normalize(newSelected);
                });
              }
            }

            print(
              '[weekly_listener] cachedEvents=${_cachedEvents.keys.length}, selected=$_selectedDay, focused=$_focusedDay',
            );
          },
          child: BlocBuilder<WeeklyScheduleBloc, WeeklyScheduleState>(
            builder: (context, state) {
              if (state.error != null && _cachedEvents.isEmpty) {
                return _ErrorView(
                  message: state.error!,
                  onRetry:
                      () => context.read<WeeklyScheduleBloc>().add(
                        WeeklyScheduleRequested(widget.email),
                      ),
                );
              }

              if (state.data != null) {
                _cachedEvents = _eventMap(state.data!.schedules);
              }

              final itemsOfDay = _itemsOfSelectedDayFromCache();
              final today = DateTime.now();

              return RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  context.read<WeeklyScheduleBloc>().add(
                    WeeklyScheduleRefreshed(widget.email, date: _selectedDay),
                  );
                  _requestAcademicWeek(_focusedDay);
                },
                child: SafeArea(
                  top: false,
                  bottom: true,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 18,
                              offset: Offset(0, 8),
                              color: Color(0x1A000000),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TableCalendar<WeeklyScheduleItem>(
                              locale: 'vi',
                              firstDay: DateTime.utc(2010, 1, 1),
                              lastDay: DateTime.utc(2035, 12, 31),
                              focusedDay: _focusedDay,
                              startingDayOfWeek: StartingDayOfWeek.monday,
                              calendarFormat: CalendarFormat.week,
                              availableCalendarFormats: const {
                                CalendarFormat.week: 'Week',
                              },
                              headerVisible: true,
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                titleTextFormatter: (date, _) {
                                  final m = DateFormat.M('vi').format(date);
                                  return 'Tháng $m, ${date.year}';
                                },
                                titleTextStyle: const TextStyle(
                                  color: Color(0xFF2A74BD),
                                  fontWeight: FontWeight.w700,
                                ),
                                leftChevronIcon: Icon(
                                  Icons.chevron_left_rounded,
                                  color: Colors.grey.shade600,
                                ),
                                rightChevronIcon: Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              onPageChanged: (d) {
                                setState(() => _focusedDay = _normalize(d));
                                _requestAcademicWeek(d);

                                final monday = _mondayOf(d);
                                final weekStart = _normalize(monday);
                                final weekEnd = _normalize(
                                  monday.add(const Duration(days: 6)),
                                );
                                final todayNorm = _normalize(DateTime.now());

                                final provisional =
                                    (!todayNorm.isBefore(weekStart) &&
                                            !todayNorm.isAfter(weekEnd))
                                        ? todayNorm
                                        : monday;

                                setState(() {
                                  _selectedDay = _normalize(provisional);
                                });

                                context.read<WeeklyScheduleBloc>().add(
                                  WeeklyScheduleRequested(
                                    widget.email,
                                    date: _selectedDay,
                                  ),
                                );
                              },

                              selectedDayPredicate:
                                  (day) => _isSameLocalDay(day, _selectedDay),

                              onDaySelected: (sel, foc) {
                                setState(() {
                                  _selectedDay = _normalize(sel);
                                  _focusedDay = _normalize(sel);
                                });

                                _ignoreNextWeeklyListener = true;

                                _requestAcademicWeek(sel);
                                context.read<WeeklyScheduleBloc>().add(
                                  WeeklyScheduleRequested(
                                    widget.email,
                                    date: _selectedDay,
                                  ),
                                );
                              },

                              eventLoader:
                                  (day) =>
                                      _cachedEvents[_normalize(day)] ??
                                      const [],

                              daysOfWeekStyle: const DaysOfWeekStyle(
                                weekdayStyle: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                                weekendStyle: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                              calendarStyle: CalendarStyle(
                                defaultTextStyle: const TextStyle(
                                  fontSize: FontSizes.small + 1,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w400,
                                ),
                                weekendTextStyle: const TextStyle(
                                  fontSize: FontSizes.small + 1,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w400,
                                ),
                                outsideTextStyle: const TextStyle(
                                  fontSize: FontSizes.small + 1,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w400,
                                ),
                                todayTextStyle: const TextStyle(
                                  fontSize: FontSizes.small + 1,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                // Focus vào hôm nay
                                todayDecoration: const BoxDecoration(
                                  color: Color(0xFFEFF3F8),
                                  shape: BoxShape.circle,
                                ),
                                selectedTextStyle: const TextStyle(
                                  fontSize: FontSizes.small + 1,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                                // Focus vào ngày được chọn
                                selectedDecoration: const BoxDecoration(
                                  color: Color(0xFFD6E6F6),
                                  shape: BoxShape.circle,
                                ),
                                cellMargin: EdgeInsets.zero,
                              ),
                              calendarBuilders: CalendarBuilders(
                                // chấm xanh: có lịch họp; chấm đỏ: hôm nay có lịch họp
                                markerBuilder: (context, day, items) {
                                  if (items.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  final isToday = _isSameLocalDay(day, today);
                                  final color =
                                      isToday
                                          ? Colors.red
                                          : const Color(0xFF2A74BD);
                                  return Positioned(
                                    bottom: 10,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                },
                                dowBuilder: (context, day) {
                                  final txt =
                                      day.weekday == DateTime.sunday
                                          ? 'CN'
                                          : 'T${day.weekday + 1}';
                                  return Center(
                                    child: Text(
                                      txt,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                        height: 1,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _academicWeekLabel.isNotEmpty
                                  ? '- $_academicWeekLabel -'
                                  : '- Tuần ${_isoWeekNumber(_selectedDay)} -',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (itemsOfDay.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 12.0),
                          child: Center(
                            child: Text('Không có lịch nào trong ngày này'),
                          ),
                        )
                      else
                        ...itemsOfDay.map((it) => _ScheduleCard(item: it)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.item});
  final WeeklyScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final tf = DateFormat('HH:mm');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => DetailScheduleDialog(item: item),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A74BD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: FontSizes.large,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${tf.format(item.start)} - ${tf.format(item.end)}',
                          style: const TextStyle(
                            fontSize: FontSizes.medium,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.location,
                          style: const TextStyle(
                            fontSize: FontSizes.medium,
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kiểm tra kết nối mạng và thử lại.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: FontSizes.medium),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
