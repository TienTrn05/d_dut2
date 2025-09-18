import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/extensions/font_sizes.dart';
import '../../../common/widgets/appbar/custom_appbar.dart';
import '../../../common/widgets/loading/loading_progress_bar.dart';

import '../bloc/results_bloc.dart';
import '../bloc/results_event.dart';
import '../bloc/results_state.dart';

import '../data/results_repository.dart';
import '../data/academic_api_client.dart';
import 'detail_result.dart';

import '../../../features/auth/bloc/auth_bloc.dart';

import '../../../features/course_registration/features/grade/presentation/widgets/semester_card.dart';

class ResultsPage extends StatefulWidget {
  final String studentId;
  final String apiBase;

  const ResultsPage({
    super.key,
    required this.studentId,
    required this.apiBase,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late final AcademicApiClient _client;
  late final ResultsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _client = AcademicApiClient(baseUrl: widget.apiBase);
    _bloc = ResultsBloc(ResultsRepository(_client));
    _bloc.add(LoadResults(widget.studentId));
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
              const CustomAppbar(label: 'Kết quả học tập'),
              BlocBuilder<ResultsBloc, ResultsState>(
                buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
                builder: (context, state) {
                  final isLoading =
                      state is ResultsInitial || state is ResultsLoading;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isLoading
                        ? SizedBox(
                            key: const ValueKey('results-loading-bar'),
                            height: 2,
                            width: double.infinity,
                            child: CustomLoadingIndicator.thin(),
                          )
                        : const SizedBox(
                            key: ValueKey('results-no-loading'),
                            height: 2,
                          ),
                  );
                },
              ),
            ],
          ),
        ),
        body: BlocBuilder<ResultsBloc, ResultsState>(
          builder: (context, state) {
            if (state is ResultsInitial || state is ResultsLoading) {
              return const SizedBox.shrink();
            }

            if (state is ResultsError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => _bloc.add(LoadResults(widget.studentId)),
              );
            }

            if (state is ResultsLoaded) {
              final all = state.subjects;

              if (all.isEmpty) {
                return RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthUserAuthenticated) {
                      _bloc.add(LoadResults(widget.studentId));
                    }
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24), // padding với màn hình
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text('Không có dữ liệu')),
                    ],
                  ),
                );
              }

              // Lấy danh sách mã kỳ và sắp xếp giảm dần (kỳ mới nhất ở trên)
              final semesters = all.map((e) => e.semesterCode).toSet().toList()
                ..sort((a, b) =>
                    (int.tryParse(b) ?? 0).compareTo(int.tryParse(a) ?? 0));

              // Gom nhóm học phần theo học kỳ
              final Map<String, List<dynamic>> grouped = {
                for (final sc in semesters)
                  sc: all.where((e) => e.semesterCode == sc).toList()
              };

              return RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthUserAuthenticated) {
                    _bloc.add(LoadResults(widget.studentId));
                  }
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                  children: [
                    for (final entry in grouped.entries) ...[
                      SemesterCard(
                        semesterCode: entry.key,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: entry.value.length,
                          itemBuilder: (context, idx) {
                            final s = entry.value[idx];
                            final hasTitle =
                                (s.subjectTitle ?? '').trim().isNotEmpty;
                            final subjectTitleText =
                                hasTitle ? s.subjectTitle!.trim() : s.classCode;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => DetailResults(
                                      subjectCode: s.classCode,
                                      subjectTitle: subjectTitleText,
                                      credits: '${s.credits ?? '-'}',
                                      detailsList: s.detailLines,
                                      congThucDiem: s.formula,
                                      tongKet: s.scoreChar,
                                      thang10: s.score10?.toStringAsFixed(1),
                                      thang4: s.score4?.toStringAsFixed(1),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2F4F7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // tên môn - điểm chữ
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              subjectTitleText,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: FontSizes.large,
                                                color: Color(0xFF2A74BD),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (s.scoreChar != null &&
                                              s.scoreChar!.trim().isNotEmpty)
                                            _GradeBadge(letter: s.scoreChar),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // số tín chỉ - điểm thang 4 - điểm thang 10
                                      _gradeMetrics(
                                        credits: s.credits?.toString(),
                                        score4: s.score4,
                                        score10: s.score10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              );
            }

            return _ErrorView(
              message: 'Lỗi tải dữ liệu',
              onRetry: () => _bloc.add(LoadResults(widget.studentId)),
            );
          },
        ),
      ),
    );
  }

  /// Tín chỉ - Điểm thang 4 - Điểm thang 10
  Widget _gradeMetrics({String? credits, double? score4, double? score10}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                'Tín chỉ',
                style: TextStyle(
                  fontSize: FontSizes.small - 1,
                  color: Colors.black45,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Điểm thang 4',
                style: TextStyle(
                  fontSize: FontSizes.small - 1,
                  color: Colors.black45,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Điểm thang 10',
                style: TextStyle(
                  fontSize: FontSizes.small - 1,
                  color: Colors.black45,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: Text(
                credits ?? '--',
                style: const TextStyle(
                  fontSize: FontSizes.small + 1,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                score4 != null ? score4.toStringAsFixed(1) : '--',
                style: const TextStyle(
                  fontSize: FontSizes.small + 1,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                score10 != null ? score10.toStringAsFixed(1) : '--',
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
    );
  }
}

class _GradeBadge extends StatelessWidget {
  final String? letter;
  const _GradeBadge({this.letter});

  Color _gradeColor(String? l) {
    switch ((l ?? '').toUpperCase()) {
      case 'A+':
      case 'A':
        return const Color(0xFF27AE60); // xanh lá
      case 'B+':
      case 'B':
        return const Color(0xFF2D9CDB); // xanh dương
      case 'C+':
      case 'C':
        return const Color(0xFFF2C94C); // vàng
      case 'D+':
      case 'D':
        return const Color(0xFFF2994A); // cam
      case 'F':
        return const Color(0xFFEB5757); // đỏ
      default:
        return Colors.black26;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (letter == null || letter!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final txt = letter!.toUpperCase();
    final c = _gradeColor(letter);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        txt,
        style: TextStyle(
          fontSize: FontSizes.medium,
          fontWeight: FontWeight.w600,
          color: c,
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
