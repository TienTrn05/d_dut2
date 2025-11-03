import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/extensions/font_sizes.dart';
import '/common/widgets/errors/error_view.dart';
import '/common/widgets/errors/network_error_view.dart';
import '/common/utils/getit_utils.dart';
import '/common/widgets/appbar/custom_appbar.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../auth/presentation/unauthorized_page.dart';
import '../bloc/tuition_fee_cubit.dart';
import '../domain/repository/tuition_fee_repo.dart';
import '../data/models/tuition_fee.dart';
import 'widgets/paid_fees_list.dart';
import 'widgets/pending_fees_list.dart';
import 'widgets/subject_fees_list.dart';

class TuitionFeeScreen extends StatelessWidget {
  const TuitionFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthUserAuthenticated) {
          return UnauthorizedPage(title: "Học phí");
        }
        return BlocProvider(
          create:
              (_) =>
                  TuitionFeeCubit(getIt<TuitionFeeRepository>())
                    ..load(authToken: authState.accessToken),
          child: Scaffold(
            appBar: const CustomAppbar(
              label: "Học phí",
              showNotificationButton: false,
            ),
            body: BlocBuilder<TuitionFeeCubit, TuitionFeeState>(
              builder: (context, state) {
                return state.when(
                  initial:
                      () => const Center(child: CircularProgressIndicator()),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  networkError:
                      (msg) => NetworkErrorView(
                        message: msg,
                        onRetry:
                            () => context.read<TuitionFeeCubit>().load(
                              authToken: authState.accessToken,
                            ),
                      ),
                  error:
                      (msg) => ErrorView(
                        message: msg,
                        onRetry:
                            () => context.read<TuitionFeeCubit>().load(
                              authToken: authState.accessToken,
                            ),
                      ),
                  loaded: (data) => _TuitionFeeContent(tuitionFees: data),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _TuitionFeeContent extends StatefulWidget {
  final List<TuitionFee> tuitionFees;
  const _TuitionFeeContent({required this.tuitionFees});

  @override
  State<_TuitionFeeContent> createState() => _TuitionFeeContentState();
}

class _TuitionFeeContentState extends State<_TuitionFeeContent> {
  int _semesterIndex = 0;
  bool _autoPickedLatestOnce = false;

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

  @override
  Widget build(BuildContext context) {
    // Thu thập các mã học kỳ và sắp xếp TĂNG dần (kỳ sau ở dưới)
    final semesters =
        widget.tuitionFees.map((e) => e.academicYearCode).toSet().toList()
          ..sort(
            (a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0),
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
    final tuitionFee =
        widget.tuitionFees
            .where((e) => e.academicYearCode == currentCode)
            .first;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 24, right: 24),
            child: _buildSemesterSelector(semesters),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 24, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PendingFeesList(tuitionFee.tuitionFees.pendingFees),

                    const SizedBox(height: 16),
                    PaidFeesList(tuitionFee.tuitionFees.paidFees),

                    const SizedBox(height: 16),
                    SubjectFeesList(tuitionFee.tuitionFees.subjectFees),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
