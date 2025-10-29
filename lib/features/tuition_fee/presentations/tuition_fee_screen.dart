import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/common/widgets/errors/error_view.dart';
import '/common/widgets/errors/network_error_view.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/presentation/unauthorized_page.dart';
import '/common/extensions/custom_theme_extension.dart';
import '/common/utils/getit_utils.dart';
import '/common/widgets/appbar/custom_appbar.dart';

import '../data/models/tuition_fee_summary.dart';
import '../bloc/tuition_fee_cubit.dart';
import '../domain/repository/tuition_fee_repo.dart';
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

class _TuitionFeeContent extends StatelessWidget {
  final TuitionFeeSummary tuitionFees;
  const _TuitionFeeContent({required this.tuitionFees});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle("🧾 Học phí sinh viên cần nộp"),
            const SizedBox(height: 8),
            PendingFeesList(tuitionFees.pendingFees),

            const SizedBox(height: 24),
            _SectionTitle("💰 Học phí đã nộp trong kỳ"),
            const SizedBox(height: 8),
            PaidFeesList(tuitionFees.paidFees),

            const SizedBox(height: 24),
            _SectionTitle("📚 Học phí lớp học phần"),
            const SizedBox(height: 8),
            SubjectFeesList(tuitionFees.subjectFees),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: context.theme.primaryColor,
      ),
    );
  }
}
