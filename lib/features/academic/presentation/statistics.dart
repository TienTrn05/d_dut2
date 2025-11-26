import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../common/extensions/font_sizes.dart';
import '../../../common/widgets/appbar/custom_appbar.dart';
import '../../../common/widgets/loading/loading_progress_bar.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../bloc/stats_bloc.dart';
import '../data/stats_repository.dart';
import '../data/academic_api_client.dart';
import '../models/stats_model.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key, required this.apiBase});

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
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthUserAuthenticated) {
      _bloc.add(StatsRequested(authToken: authState.accessToken));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    _client.close();
    super.dispose();
  }

  double? _overallGpa4(StatsModel d) {
    if (d.gpa4 != null) return d.gpa4;
    return null;
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
                    child:
                        state.isLoading
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
        body: SafeArea(
          child: BlocBuilder<StatsBloc, StatsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const SizedBox.shrink();
              }
              if (state.error != null) {
                return _ErrorView(
                  message: state.error!,
                  onRetry: () {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthUserAuthenticated) {
                      _bloc.add(
                        StatsRequested(authToken: authState.accessToken),
                      );
                    }
                  },
                );
              }

              final StatsModel data = state.data!;

              final semesters = data.semesters;
              final displaySemesters =
                  semesters.map(_formatSemesterShort).toList();

              final gpaPerSem = data.gpaPerSemester; // DiemTBTL (0-4)
              final conductScores =
                  data.conductPerSemester; // ĐRL 0-100 (mỗi kỳ)
              final credits =
                  data.creditsPerSemester.map((e) => e.toDouble()).toList();

              final double? overallGpa4 = _overallGpa4(data);
              final double totalAccumCredits =
                  data.totalAccumCredits?.toDouble() ?? 0.0;

              // Điểm rèn luyện trung bình
              final double? avgConduct =
                  data.avgConduct ??
                  (conductScores.isEmpty
                      ? null
                      : conductScores.reduce((a, b) => a + b) /
                          conductScores.length);

              final String? studyStage = data.stage; // Năm học

              final double creditsYMax = () {
                if (credits.isEmpty) return 20.0;
                final maxVal = credits.reduce(math.max);
                final rounded = (((maxVal ~/ 10) + 1) * 10).toDouble();
                return math.max(rounded, 20.0);
              }();

              return RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthUserAuthenticated) {
                    _bloc.add(StatsRequested(authToken: authState.accessToken));
                  }
                  await _bloc.stream
                      .skipWhile((s) => !s.isLoading)
                      .firstWhere((s) => !s.isLoading);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  children: [
                    // Tổng quan học vụ
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F1F9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                            offset: Offset(0, 4),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _BigMetricCard(
                              value:
                                  overallGpa4 == null
                                      ? '--'
                                      : overallGpa4.toStringAsFixed(2),
                            ),
                            Container(
                              width: 1,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              color: const Color(0xFFBAC7D5).withOpacity(0.6),
                            ),
                            Expanded(
                              child: _InfoSummaryInline(
                                totalAccumCredits: totalAccumCredits,
                                avgConduct: avgConduct,
                                studyStage: studyStage,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // GPA (thang 4.0)
                    _ChartCard(
                      title: 'Điểm tích luỹ theo từng kỳ',
                      child:
                          gpaPerSem.isNotEmpty
                              ? _LineChart(
                                xLabels: displaySemesters,
                                values: gpaPerSem,
                                minY: 0,
                                maxY: 4,
                                yInterval: 1,
                              )
                              : const _EmptyChart(),
                    ),
                    const SizedBox(height: 12),

                    // Điểm rèn luyện
                    _ChartCard(
                      title: 'Điểm rèn luyện theo từng kỳ',
                      child:
                          conductScores.isNotEmpty
                              ? _LineChart(
                                xLabels: displaySemesters,
                                values: conductScores,
                                minY: 0,
                                maxY: 100,
                                yInterval: 20,
                              )
                              : const _EmptyChart(),
                    ),
                    const SizedBox(height: 12),

                    // Số TC đăng ký
                    _ChartCard(
                      title: 'Số tín chỉ đăng ký từng kỳ',
                      child:
                          credits.isNotEmpty
                              ? _LineChart(
                                xLabels: displaySemesters,
                                values: credits,
                                minY: 0,
                                maxY: creditsYMax,
                                yInterval: 10,
                                tooltipDigits: 1,
                              )
                              : const _EmptyChart(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatSemesterShort(String raw) {
    var s = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (s.isEmpty) return raw;
    final hk = s.characters.last;
    final yy =
        (s.length >= 3)
            ? s.substring(s.length - 3, s.length - 1)
            : s.padLeft(2, '0').substring(0, 2);
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
      color: const Color(0xFFFAFAFA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    this.tooltipDigits,
  });

  final List<String> xLabels;
  final List<double> values;
  final double? minY, maxY, yInterval;
  final int? tooltipDigits;

  @override
  Widget build(BuildContext context) {
    final len = math.min(xLabels.length, values.length);
    final labels = xLabels.take(len).toList();
    final spots = <FlSpot>[
      for (int i = 0; i < len; i++) FlSpot(i.toDouble(), values[i]),
    ];

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
              tooltipBorder: const BorderSide(
                color: Color(0xFF133D87),
                width: 1.0,
              ),
              getTooltipItems:
                  (touchedSpots) =>
                      touchedSpots.map((spot) {
                        final v = spot.y;
                        final isConductChart =
                            (maxY ?? 0) == 100; // điểm rèn luyện
                        final digits =
                            isConductChart ? 0 : (tooltipDigits ?? 2);
                        final text = v.toStringAsFixed(digits);
                        return LineTooltipItem(
                          text,
                          const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF133D87),
                            fontSize: FontSizes.medium,
                          ),
                        );
                      }).toList(),
            ),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: borderColor, width: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: yInterval ?? 1,
                reservedSize: 32,
                getTitlesWidget: (v, meta) {
                  final interval = yInterval ?? 1.0;
                  final isTick = (v % interval).abs() < 1e-6;
                  if (!isTick) return const SizedBox.shrink();
                  final text =
                      v == v.roundToDouble()
                          ? v.toInt().toString()
                          : v.toStringAsFixed(1);
                  return SideTitleWidget(
                    space: 6,
                    meta: meta,
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: FontSizes.small),
                    ),
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
                  if (i < 0 || i >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  final shouldShow = labels.length <= 10 || i % 2 == 0;
                  if (!shouldShow) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      labels[i],
                      style: const TextStyle(fontSize: FontSizes.small),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              barWidth: 2,
              color: const Color(0xFF2A74BD),
              dotData: const FlDotData(show: true),
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
    required this.totalAccumCredits,
    this.avgConduct,
    this.studyStage,
  });

  final double totalAccumCredits; // HPTichLuy (kỳ mới nhất)
  final double? avgConduct; // trung bình DiemRL các kỳ
  final String? studyStage; // Namhoc (string)

  static const Color _labelColor = Color(0xFF424242);
  static const TextStyle _labelStyle = TextStyle(
    color: _labelColor,
    fontSize: FontSizes.medium,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle _valueStyle = TextStyle(
    color: Colors.black,
    fontSize: FontSizes.medium,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    final conductDisplay =
        (avgConduct == null) ? '—' : avgConduct!.toStringAsFixed(0);
    final stageDisplay =
        (studyStage == null || studyStage!.trim().isEmpty)
            ? '—'
            : studyStage!.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: 'Số tín chỉ tích luỹ: ', style: _labelStyle),
              TextSpan(
                text: totalAccumCredits.toStringAsFixed(0),
                style: _valueStyle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Điểm rèn luyện trung bình: ',
                style: _labelStyle,
              ),
              TextSpan(text: conductDisplay, style: _valueStyle),
            ],
          ),
        ),
        const SizedBox(height: 6),

        RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: 'Năm học: Năm thứ ', style: _labelStyle),
              TextSpan(text: stageDisplay, style: _valueStyle),
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
              'Kiểm tra kết nối Internet và tải lại trang',
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
