import 'package:injectable/injectable.dart';
import '../../data/data_sources/remote_data_sources/tuition_fee_service.dart';
import '../../data/models/pending_tuition_fee.dart';
import '../../data/models/paid_tuition_fee.dart';
import '../../data/models/tuition_fee_by_subject.dart';
import '../../data/models/tuition_fee_summary.dart';

@singleton
class TuitionFeeRepository {
  final TuitionFeeService _tuitionFeeService;

  TuitionFeeRepository(this._tuitionFeeService);

  Future<List<PendingTuitionFee>> getPendingTuitionFees(String authToken) {
    return _tuitionFeeService.getPendingTuitionFees(authToken);
  }

  Future<List<PaidTuitionFee>> getPaidTuitionFees(String authToken) {
    return _tuitionFeeService.getPaidTuitionFees(authToken);
  }

  Future<List<TuitionFeeBySubject>> getTuitionFeesBySubject(String authToken) {
    return _tuitionFeeService.getTuitionFeesBySubject(authToken);
  }

  /// 👉 Hàm tổng hợp, gom 3 API lại
  Future<TuitionFeeSummary> getTuitionFeeSummary(
    String authToken,
  ) async {
    final pendingFuture = getPendingTuitionFees(authToken);
    final paidFuture = getPaidTuitionFees(authToken);
    final subjectFuture = getTuitionFeesBySubject(authToken);

    final results = await Future.wait([
      pendingFuture,
      paidFuture,
      subjectFuture,
    ]);

    return TuitionFeeSummary(
      pendingFees: results[0] as List<PendingTuitionFee>,
      paidFees: results[1] as List<PaidTuitionFee>,
      subjectFees: results[2] as List<TuitionFeeBySubject>,
    );
  }
}
