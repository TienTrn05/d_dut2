import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  int _semesterIndex = 0;
  bool _autoPickedLatestOnce = false;

  late final AcademicApiClient _client;
  late final ResultsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _client = AcademicApiClient(baseUrl: widget.apiBase);
    _bloc = ResultsBloc(ResultsRepository(_client));
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthUserAuthenticated) {
      _bloc.add(LoadResults(authState.accessToken));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    _client.close();
    super.dispose();
  }

  // --------------------------
  // Semester selector helpers
  // --------------------------
  void _previousSemester(List<String> semesters) {
    if (_semesterIndex > 0) setState(() => _semesterIndex--);
  }

  void _nextSemester(List<String> semesters) {
    if (_semesterIndex < semesters.length - 1) setState(() => _semesterIndex++);
  }

  void _showSemesterPicker(BuildContext context, List<String> semesters) {
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
                        initialItem: _semesterIndex,
                      ),
                      onSelectedItemChanged: (int index) {
                        if (_semesterIndex != index) {
                          setState(() => _semesterIndex = index);
                        }
                      },
                      selectionOverlay: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.withAlpha(30),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      children: [
                        for (int i = 0; i < semesters.length; i++)
                          Center(
                            child: Text(
                              _formatSemesterTitle(semesters[i]),
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

  Widget _buildSemesterSelector(List<String> semesters) {
    final currentCode = semesters[_semesterIndex];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 24.0,
        children: [
          GestureDetector(
            onTap: () => _previousSemester(semesters),
            child: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _showSemesterPicker(context, semesters),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4.0),
                child: Center(
                  child: Text(
                    _formatSemesterTitle(currentCode),
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
            onTap: () => _nextSemester(semesters),
            child: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        ],
      ),
    );
  }

  // --------------------------
  // UI
  // --------------------------
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
                    child:
                        isLoading
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
                onRetry: () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthUserAuthenticated) {
                    _bloc.add(LoadResults(authState.accessToken));
                  }
                },
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
                      _bloc.add(LoadResults(authState.accessToken));
                    }
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text('Không có dữ liệu')),
                    ],
                  ),
                );
              }

              // Thu thập các mã học kỳ và sắp xếp TĂNG dần (kỳ sau ở dưới)
              final semesters =
                  all.map((e) => e.semesterCode).toSet().toList()..sort(
                    (a, b) =>
                        (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0),
                  );

              // Auto chọn kỳ mới nhất lần đầu
              if (!_autoPickedLatestOnce && semesters.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() {
                    _semesterIndex = semesters.length - 1;
                    _autoPickedLatestOnce = true;
                  });
                });
              }

              // An toàn chỉ số
              if (_semesterIndex >= semesters.length) {
                _semesterIndex = semesters.length - 1;
              } else if (_semesterIndex < 0) {
                _semesterIndex = 0;
              }

              final currentCode = semesters[_semesterIndex];
              final items =
                  all.where((e) => e.semesterCode == currentCode).toList();

              return RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthUserAuthenticated) {
                    _bloc.add(LoadResults(authState.accessToken));
                  }
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24), // cách AppBar 24dp
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildSemesterSelector(semesters);
                    }

                    final s = items[index - 1];
                    final hasTitle = (s.subjectTitle ?? '').trim().isNotEmpty;
                    final subjectTitleText =
                        hasTitle ? s.subjectTitle!.trim() : s.classCode;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => DetailResults(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hàng 1: Tên môn + badge điểm chữ
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                              // Hàng 2–3: Tín chỉ – Điểm thang 4 – Điểm thang 10
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
              );
            }

            return _ErrorView(
              message: 'Lỗi tải dữ liệu',
              onRetry: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthUserAuthenticated) {
                  _bloc.add(LoadResults(authState.accessToken));
                }
              },
            );
          },
        ),
      ),
    );
  }

  /// Quy tắc: XXYY, với YY là học kì (10: HK1, 20: HK2, 21: Hè)
  String _formatSemesterTitle(String code) {
    final safe = code.padLeft(4, '0');
    final yy = safe.substring(0, 2);
    final hk = safe.substring(2);
    final startYear = 2000 + (int.tryParse(yy) ?? 0);
    final endYear = startYear + 1;

    final hkText = switch (hk) {
      '10' => 'Học kỳ 1',
      '20' => 'Học kỳ 2',
      '21' => 'Học kỳ hè',
      _ => 'Học kỳ 2',
    };
    return '$hkText, $startYear-$endYear';
  }

  // Block 3 cột căn thẳng
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
        return const Color(0xFF27AE60);
      case 'B+':
      case 'B':
        return const Color(0xFF2D9CDB);
      case 'C+':
      case 'C':
        return const Color(0xFFF2C94C);
      case 'D+':
      case 'D':
        return const Color(0xFFF2994A);
      case 'F':
        return const Color(0xFFEB5757);
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
        color: c.withOpacity(0.08), // không viền
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
