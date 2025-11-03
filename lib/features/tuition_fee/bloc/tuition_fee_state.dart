part of 'tuition_fee_cubit.dart';

@freezed
class TuitionFeeState with _$TuitionFeeState {
  const factory TuitionFeeState.initial() = _Initial;
  const factory TuitionFeeState.loading() = _Loading;
  const factory TuitionFeeState.loaded({
    required List<TuitionFee> tuitionFees,
  }) = _Loaded;
  const factory TuitionFeeState.error(String message) = _Error;
  const factory TuitionFeeState.networkError(String message) = _NetworkError;
}
