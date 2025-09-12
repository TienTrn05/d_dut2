import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../bloc/results_bloc.dart';
import '../bloc/results_event.dart';
import '../bloc/results_state.dart';

import '../data/results_repository.dart';
import '../data/academic_api_client.dart';
import 'detail_result.dart';

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
        appBar: AppBar(
          title: const Text('Kết quả học tập'),
          centerTitle: true,
          backgroundColor: const Color(0xFF2A74BD),
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            tooltip: null,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SvgPicture.asset(
                'assets/icons/svg/solar_bell-bold.svg',
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: BlocBuilder<ResultsBloc, ResultsState>(
          builder: (context, state) {
            if (state is ResultsInitial || state is ResultsLoading) {
              return const Center(child: CircularProgressIndicator());
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
                  onRefresh: () async =>
                      _bloc.add(LoadResults(widget.studentId)),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text('Không có dữ liệu')),
                    ],
                  ),
                );
              }

              // danh sách kỳ, sort giảm dần theo mã kỳ
              final semesters = all.map((e) => e.semesterCode).toSet().toList()
                ..sort((a, b) =>
                    (int.tryParse(b) ?? 0).compareTo(int.tryParse(a) ?? 0));

              if (_semesterIndex >= semesters.length) _semesterIndex = 0;
              if (semesters.isEmpty) {
                return const Center(child: Text('Không có dữ liệu học kỳ'));
              }

              final currentCode = semesters[_semesterIndex];
              final items =
                  all.where((e) => e.semesterCode == currentCode).toList();

              return RefreshIndicator(
                onRefresh: () async => _bloc.add(LoadResults(widget.studentId)),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left,
                                  color: Colors.black54),
                              onPressed: _semesterIndex < semesters.length - 1
                                  ? () => setState(() => _semesterIndex++)
                                  : null,
                            ),
                            Text(
                              _formatSemesterTitle(currentCode),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right,
                                  color: Colors.black54),
                              onPressed: _semesterIndex > 0
                                  ? () => setState(() => _semesterIndex--)
                                  : null,
                            ),
                          ],
                        ),
                      );
                    }

                    final s = items[index - 1];
                    final hasTitle = (s.subjectTitle ?? '').trim().isNotEmpty;
                    final subjectTitleText =
                        hasTitle ? s.subjectTitle!.trim() : s.classCode;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6.0),
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
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.classCode,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black45),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      subjectTitleText,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF2A74BD),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Số TC: ${s.credits ?? '-'}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                s.scoreChar ?? '--/--',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black45,
                                  fontWeight: FontWeight.w600,
                                ),
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
              onRetry: () => _bloc.add(LoadResults(widget.studentId)),
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
      '10' => 'HỌC KÌ 1',
      '20' => 'HỌC KÌ 2',
      '21' => 'HỌC KÌ HÈ',
      _ => 'HỌC KÌ 2',
    };
    return '$hkText, $startYear-$endYear';
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
            Text('Lỗi: $message', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
