import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
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
    emit(const TuitionFeeState.loading());

    try {
      final summary = await _tuitionFeeRepository.getTuitionFeeSummary(
        authToken,
      );
      emit(TuitionFeeState.loaded(tuitionFees: summary));
    } on DioException catch (e) {
      // 🧭 Bắt lỗi mạng & server từ Dio
      if (e.error is SocketException ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        emit(
          const TuitionFeeState.networkError(
            "Kết nối mạng bị gián đoạn hoặc máy chủ không phản hồi. Vui lòng thử lại sau.",
          ),
        );
      } else {
        emit(
          const TuitionFeeState.error(
            "Không thể tải thông tin học phí.\nVui lòng thử lại sau.",
          ),
        );
      }
    } on TimeoutException {
      emit(
        const TuitionFeeState.networkError(
          "Máy chủ phản hồi chậm.\nVui lòng thử lại sau.",
        ),
      );
    } on SocketException {
      emit(
        const TuitionFeeState.networkError(
          "Không thể kết nối Internet.\nVui lòng kiểm tra kết nối mạng.",
        ),
      );
    } catch (_) {
      emit(
        const TuitionFeeState.error(
          "Đã xảy ra lỗi không xác định.\nVui lòng thử lại sau.",
        ),
      );
    }
  }
}
