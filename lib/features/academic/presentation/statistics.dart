import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../common/extensions/font_sizes.dart';
import '../../../common/widgets/appbar/custom_appbar.dart';
import '../../../common/widgets/loading/loading_progress_bar.dart';

import '../bloc/stats_bloc.dart';
import '../data/stats_repository.dart';
import '../data/academic_api_client.dart';
import '../models/stats_model.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({
    super.key,
    required this.studentId,
    required this.apiBase,
  });

  final String studentId;
  final String apiBase;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late final AcademicApiClient _client;
  late final StatsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _client = AcademicApiClient(baseUrl: widget.apiBase);
    _bloc = StatsBloc(StatsRepository(_client));
    _bloc.add(StatsRequested(studentId: widget.studentId));
  }

  @override
  void dispose() {
    _bloc.close();
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomAppbar(label: 'Học vụ'),
              BlocBuilder<StatsBloc, StatsState>(
                buildWhen: (p, c) => p.isLoading != c.isLoading,
                builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: state.isLoading
                        ? SizedBox(
                            key: const ValueKey('stats-loading-bar'),
                            height: 2,
                            width: double.infinity,
                            child: CustomLoadingIndicator.thin(),
                          )
                        : const SizedBox(
                            key: ValueKey('stats-no-loading'),
                            height: 2,
                          ),
                  );
                },
              ),
            ],
          ),
        ),
        body: BlocBuilder<StatsBloc, StatsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const SizedBox.shrink();
            }
            if (state.error != null) {
              return _ErrorView(
                message: state.error!,
                onRetry: () =>
                    _bloc.add(StatsRequested(studentId: widget.studentId)),
              );
            }

            final StatsModel data = state.data!;

            final semesters = data.semesters;
            final displaySemesters =
                semesters.map(_formatSemesterShort).toList();

            final gpaPerSem = data.gpaPerSemester; // thang 4
            final conductScores = data.conductPerSemester; // ĐRL 0-100
            final credits =
                data.creditsPerSemester.map((e) => e.toDouble()).toList();

            final double? overallGpa4 = data.gpa4 ?? data.gpa10;
            final double totalCredits = data.totalCredits.toDouble();
            final String? warningLevel = data.warningLevel;
            final String? studyStage = data.stage;

            final double creditsYMax = () {
              if (credits.isEmpty) return 10.0;
              final maxVal = credits.reduce(math.max);
              return (((maxVal ~/ 10) + 1) * 10).toDouble();
            }();

            return RefreshIndicator(
              color: Theme.of(context).primaryColor,
              backgroundColor: Colors.white,
              onRefresh: () async =>
                  _bloc.add(StatsRefreshed(studentId: widget.studentId)),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                children: [
                  // --- Card tổng quan (E7F1F9, radius 16) ---
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F1F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _BigMetricCard(
                            value: overallGpa4 == null
                                ? '--'
                                : overallGpa4.toStringAsFixed(2),
                          ),
                          Container(
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            color: const Color(0xFFBAC7D5).withOpacity(0.6),
                          ),
                          Expanded(
                            child: _InfoSummaryInline(
                              totalCredits: totalCredits,
                              warningLevel: warningLevel?.toString(),
                              studyStage: studyStage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- GPA ---
                  _ChartCard(
                    title: 'GPA',
                    child: _LineChart(
                      xLabels: displaySemesters,
                      values: gpaPerSem,
                      minY: 0,
                      maxY: 4,
                      yInterval: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Điểm rèn luyện ---
                  _ChartCard(
                    title: 'Điểm rèn luyện',
                    child: conductScores.isNotEmpty
                        ? _LineChart(
                            xLabels: displaySemesters,
                            values: conductScores,
                            minY: 0,
                            maxY: 100,
                            yInterval: 10,
                          )
                        : const _EmptyChart(),
                  ),
                  const SizedBox(height: 12),

                  // --- Số TC đăng ký ---
                  _ChartCard(
                    title: 'Số tín chỉ đăng ký từng kỳ',
                    child: _LineChart(
                      xLabels: displaySemesters,
                      values: credits,
                      minY: 0,
                      maxY: creditsYMax,
                      yInterval: 5,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Định dạng học kỳ XX.Y
  String _formatSemesterShort(String raw) {
    var s = raw.trim();
    if (s.length < 3) s = s.padLeft(3, '0');
    final yy = s.substring(0, 2);
    final hk = s.substring(s.length - 1);
    return '$yy.$hk';
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: const Color(0xFFFAFAFA), // nền container đồ thị
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // bo tròn 16
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: FontSizes.medium,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(height: 220, child: child),
          ],
        ),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({
    required this.xLabels,
    required this.values,
    this.minY,
    this.maxY,
    this.yInterval,
  });

  final List<String> xLabels;
  final List<double> values;
  final double? minY, maxY, yInterval;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];

    // màu xám nhạt tương tự grid (fl_chart mặc định với Theme.of(context).dividerColor)
    final borderColor = const Color(0xFF9E9E9E).withOpacity(0.3);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.white,
              tooltipBorder:
                  const BorderSide(color: Color(0xFF133D87), width: 1.0),
              getTooltipItems: (touchedSpots) => touchedSpots
                  .map((spot) => LineTooltipItem(
                        spot.y.toString(),
                        const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF133D87),
                          fontSize: FontSizes.medium,
                        ),
                      ))
                  .toList(),
            ),
          ),
          gridData: FlGridData(show: true),
          // Làm mờ khung viền như grid
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: borderColor, width: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: yInterval,
                getTitlesWidget: (v, meta) {
                  final d = (v * 2).roundToDouble() / 2.0;
                  final isTick = (v - d).abs() < 1e-6;
                  if (!isTick) return const SizedBox.shrink();
                  return Text(
                    (v % 1 == 0) ? v.toInt().toString() : v.toStringAsFixed(1),
                    style: const TextStyle(fontSize: FontSizes.small),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= xLabels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      xLabels[i],
                      style: const TextStyle(fontSize: FontSizes.small),
                    ),
                  );
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              barWidth: 2,
              color: const Color(0xFF2A74BD),
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigMetricCard extends StatelessWidget {
  const _BigMetricCard({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 4),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: Color(0xFF2A74BD),
        ),
      ),
    );
  }
}

class _InfoSummaryInline extends StatelessWidget {
  const _InfoSummaryInline({
    required this.totalCredits,
    this.warningLevel,
    this.studyStage,
  });

  final double totalCredits;
  final String? warningLevel;
  final String? studyStage;

  @override
  Widget build(BuildContext context) {
    String stageDisplay = '—';
    if (studyStage != null && studyStage!.trim().isNotEmpty) {
      stageDisplay = 'Năm thứ ${studyStage!}';
    }

    TextSpan b(String txt) => TextSpan(
          text: txt,
          style: const TextStyle(fontWeight: FontWeight.w700),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
                color: Colors.black87, fontSize: FontSizes.medium),
            children: [
              const TextSpan(text: 'Số tín chỉ tích luỹ: '),
              b(totalCredits.toStringAsFixed(0)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: const TextStyle(
                color: Colors.black87, fontSize: FontSizes.medium),
            children: [
              const TextSpan(text: 'Mức cảnh báo học tập: '),
              b(warningLevel ?? '—'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: const TextStyle(
                color: Colors.black87, fontSize: FontSizes.medium),
            children: [
              const TextSpan(text: 'Năm học: '),
              b(stageDisplay),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Không có dữ liệu',
        style: TextStyle(
          color: Colors.black.withOpacity(0.6),
          fontSize: FontSizes.medium,
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
