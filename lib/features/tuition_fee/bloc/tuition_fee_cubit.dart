import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '/common/mixin/cancelable_base_bloc.dart';
import '/features/tuition_fee/domain/repository/tuition_fee_repo.dart';
import '../data/models/tuition_fee_summary.dart';

part 'tuition_fee_cubit.freezed.dart';
part 'tuition_fee_state.dart';

class TuitionFeeCubit extends Cubit<TuitionFeeState>
    with CancelableBaseBloc<TuitionFeeState> {
  final TuitionFeeRepository _tuitionFeeRepository;

  TuitionFeeCubit(this._tuitionFeeRepository)
    : super(const TuitionFeeState.initial());

  Future<void> load({required String authToken}) async {
    try {
      emit(TuitionFeeState.loading());
      final summary = await _tuitionFeeRepository.getTuitionFeeSummary(
        authToken,
      );

      emit(TuitionFeeState.loaded(tuitionFees: summary));
    } on SocketException catch (_) {
      // 🛜 Lỗi mạng / không có Internet
      emit(
        const TuitionFeeState.networkError(
          "Mạng chậm chờn hoặc bị mất kết nối. Vui lòng kiểm tra lại mạng và thử lại.",
        ),
      );
    } on TimeoutException catch (_) {
      // ⏱️ Server phản hồi quá lâu
      emit(
        const TuitionFeeState.networkError(
          "Máy chủ phản hồi chậm. Vui lòng thử lại sau.",
        ),
      );
    } catch (e) {
      // ❌ Lỗi khác
      emit(TuitionFeeState.error(e.toString()));
    }
  }
}
