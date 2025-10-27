import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../common/extensions/font_sizes.dart';
import '../../../common/widgets/loading/loading_progress_bar.dart';

import '../bloc/weekly_schedule_bloc.dart';
import '../models/weekly_schedule_model.dart';
import 'detail_schedule.dart';

class WeeklySchedulePage extends StatefulWidget {
  const WeeklySchedulePage({super.key, required this.email});
  final String email;

  @override
  State<WeeklySchedulePage> createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage> {
  late DateTime _selectedMonday;
  bool _autoInit = false;

  @override
  void initState() {
    super.initState();
    _selectedMonday = _mondayOf(DateTime.now());
  }

  DateTime _mondayOf(DateTime date) =>
      date.subtract(Duration(days: (date.weekday == 7 ? 0 : date.weekday) - 1));

  void _shiftWeek(int delta) {
    setState(
      () => _selectedMonday = _selectedMonday.add(Duration(days: 7 * delta)),
    );
  }

  void _showWeekPicker(BuildContext context) {
    final base = DateTime.now();
    final start = _mondayOf(DateTime(base.year, 1, 1));
    final weeks = List<DateTime>.generate(
      53,
      (i) => start.add(Duration(days: i * 7)),
    );

    final currIndex = weeks.indexWhere(
      (d) =>
          d.year == _selectedMonday.year &&
          d.month == _selectedMonday.month &&
          d.day == _selectedMonday.day,
    );
    final initial = currIndex >= 0 ? currIndex : weeks.length ~/ 2;

    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 200,
                    child: CupertinoPicker(
                      backgroundColor: Colors.transparent,
                      itemExtent: 52,
                      scrollController: FixedExtentScrollController(
                        initialItem: initial,
                      ),
                      onSelectedItemChanged: (int index) {
                        setState(() => _selectedMonday = weeks[index]);
                      },
                      selectionOverlay: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.withAlpha(30),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      children: [
                        for (final d in weeks)
                          Center(
                            child: Text(
                              _formatWeekTitle(d),
                              style: const TextStyle(
                                fontSize: FontSizes.large,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                            ),
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

  String _formatWeekTitle(DateTime monday) {
    final week = _isoWeekNumber(monday);
    final monthYear = DateFormat('MMMM, yyyy', 'vi').format(monday);
    return 'Tuần $week — $monthYear';
  }

  int _isoWeekNumber(DateTime date) {
    final thursday = date.add(Duration(days: 3 - (date.weekday + 6) % 7));
    final firstThursday = DateTime(thursday.year, 1, 4);
    return 1 +
        ((thursday.millisecondsSinceEpoch -
                firstThursday.millisecondsSinceEpoch) ~/
            604800000);
  }

  Map<DateTime, List<WeeklyScheduleItem>> _groupByDay(
    List<WeeklyScheduleItem> src,
    DateTime monday,
  ) {
    final start = monday;
    final end = monday.add(const Duration(days: 7));

    final filtered =
        src.where((e) => !e.day.isBefore(start) && e.day.isBefore(end)).toList()
          ..sort((a, b) => a.start.compareTo(b.start));

    final map = <DateTime, List<WeeklyScheduleItem>>{};
    for (final it in filtered) {
      final key = DateTime(it.day.year, it.day.month, it.day.day);
      map.putIfAbsent(key, () => []).add(it);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Lịch tuần',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: FontSizes.large,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            BlocBuilder<WeeklyScheduleBloc, WeeklyScheduleState>(
              buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
              builder: (context, state) {
                final isLoading = state.isLoading;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child:
                      isLoading
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
      body: BlocBuilder<WeeklyScheduleBloc, WeeklyScheduleState>(
        builder: (context, state) {
          if (!_autoInit) {
            _autoInit = true;
          }

          if (state.isLoading) {
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
          final groups = _groupByDay(data.schedules, _selectedMonday);

          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: Colors.white,
            onRefresh:
                () async => context.read<WeeklyScheduleBloc>().add(
                  WeeklyScheduleRefreshed(widget.email),
                ),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                _buildWeekSelector(),
                const SizedBox(height: 4),
                if (groups.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 120.0),
                    child: Center(child: Text('Lịch trống')),
                  )
                else
                  ...groups.entries.map(
                    (e) => _DaySection(date: e.key, items: e.value),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeekSelector() {
    final monday = _selectedMonday;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _shiftWeek(-1),
            child: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _showWeekPicker(context),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4.0),
                child: Center(
                  child: Text(
                    _formatWeekTitle(monday),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: FontSizes.medium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _shiftWeek(1),
            child: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.date, required this.items});
  final DateTime date;
  final List<WeeklyScheduleItem> items;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEEE, dd/MM/yyyy', 'vi');
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            df.format(date),
            style: const TextStyle(
              fontSize: FontSizes.large,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          ...items.map((it) => _ScheduleCard(item: it)),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => DetailScheduleDialog(item: item),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Container(width: 4, height: 52, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: FontSizes.large,
                        color: Color(0xFF2A74BD),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${tf.format(item.start)} - ${tf.format(item.end)}',
                          style: const TextStyle(
                            fontSize: FontSizes.small + 1,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: FontSizes.small + 1,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
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
              'Lỗi: $message',
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
