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

class WeeklySchedulePage extends StatefulWidget {
  const WeeklySchedulePage({super.key, required this.email});
  final String email;

  @override
  State<WeeklySchedulePage> createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  bool _autoInit = false;

  // Tuần theo năm học
  String _academicWeekLabel = '';

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  int _isoWeekNumber(DateTime date) {
    final thursday = date.add(Duration(days: 3 - (date.weekday + 6) % 7));
    final firstThursday = DateTime(thursday.year, 1, 4);
    return 1 +
        ((thursday.millisecondsSinceEpoch -
                firstThursday.millisecondsSinceEpoch) ~/
            604800000);
  }

  // Thứ Hai của tuần chứa day
  DateTime _mondayOf(DateTime day) =>
      day.subtract(Duration(days: (day.weekday == 7 ? 0 : day.weekday) - 1));

  // Gọi API tuần theo năm học
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

  // Gom lịch theo ngày
  Map<DateTime, List<WeeklyScheduleItem>> _eventMap(
    List<WeeklyScheduleItem> items,
  ) {
    final map = <DateTime, List<WeeklyScheduleItem>>{};
    for (final it in items) {
      final key = DateTime(it.day.year, it.day.month, it.day.day);
      (map[key] ??= []).add(it);
    }
    return map;
  }

  // Lịch của ngày đang chọn
  List<WeeklyScheduleItem> _itemsOfSelectedDay(List<WeeklyScheduleItem> items) {
    return items
        .where(
          (it) =>
              it.day.year == _selectedDay.year &&
              it.day.month == _selectedDay.month &&
              it.day.day == _selectedDay.day,
        )
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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
                final showLoading = state.isLoading && state.data == null;
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

      // Cập nhật tuần theo năm học
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
        child: BlocBuilder<WeeklyScheduleBloc, WeeklyScheduleState>(
          builder: (context, state) {
            if (!_autoInit) {
              _autoInit = true;
              context.read<WeeklyScheduleBloc>().add(
                WeeklyScheduleRequested(widget.email),
              );
              _requestAcademicWeek(_focusedDay); // gọi lấy tuần học
            }

            if (state.isLoading && state.data == null) {
              return const SizedBox.shrink();
            }

            if (state.error != null) {
              return _ErrorView(
                message: state.error!,
                onRetry:
                    () => context.read<WeeklyScheduleBloc>().add(
                      WeeklyScheduleRequested(widget.email),
                    ),
              );
            }

            final data = state.data!;
            final events = _eventMap(data.schedules);
            final itemsOfDay = _itemsOfSelectedDay(data.schedules);
            final today = DateTime.now();

            return RefreshIndicator(
              color: Theme.of(context).primaryColor,
              backgroundColor: Colors.white,
              onRefresh: () async {
                context.read<WeeklyScheduleBloc>().add(
                  WeeklyScheduleRefreshed(widget.email),
                );
                _requestAcademicWeek(_focusedDay);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // Card lịch tuần
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
                            setState(() => _focusedDay = d);
                            _requestAcademicWeek(d);
                          },

                          selectedDayPredicate:
                              (day) =>
                                  day.year == _selectedDay.year &&
                                  day.month == _selectedDay.month &&
                                  day.day == _selectedDay.day,
                          onDaySelected: (sel, foc) {
                            setState(() {
                              _selectedDay = sel;
                              _focusedDay = foc;
                            });
                            _requestAcademicWeek(foc);
                          },

                          eventLoader:
                              (day) =>
                                  events[DateTime(
                                    day.year,
                                    day.month,
                                    day.day,
                                  )] ??
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
                            todayDecoration: const BoxDecoration(
                              color: Color(0xFFEFF3F8),
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: const TextStyle(
                              fontSize: FontSizes.small + 1,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: Color(0xFFD6E6F6),
                              shape: BoxShape.circle,
                            ),
                            cellMargin: EdgeInsets.zero,
                          ),
                          calendarBuilders: CalendarBuilders(
                            // chấm xanh: có lịch họp; chấm đỏ: hôm nay có lịch họp
                            markerBuilder: (context, day, items) {
                              if (items.isEmpty) return const SizedBox.shrink();
                              final isToday =
                                  day.year == today.year &&
                                  day.month == today.month &&
                                  day.day == today.day;
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
                          // Dùng tuần theo năm học
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

                  // Danh sách lịch ngày đang chọn
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
            );
          },
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
