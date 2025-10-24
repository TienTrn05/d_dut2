import 'pending_tuition_fee.dart';
import 'paid_tuition_fee.dart';
import 'tuition_fee_by_subject.dart';

class TuitionFeeSummary {
  final List<PendingTuitionFee> pendingFees;
  final List<PaidTuitionFee> paidFees;
  final List<TuitionFeeBySubject> subjectFees;

  TuitionFeeSummary({
    required this.pendingFees,
    required this.paidFees,
    required this.subjectFees,
  });

  factory TuitionFeeSummary.fromJson(Map<String, dynamic> json) {
    return TuitionFeeSummary(
      pendingFees:
          (json['pendingFees'] as List<dynamic>)
              .map((e) => PendingTuitionFee.fromJson(e))
              .toList(),
      paidFees:
          (json['paidFees'] as List<dynamic>)
              .map((e) => PaidTuitionFee.fromJson(e))
              .toList(),
      subjectFees:
          (json['subjectFees'] as List<dynamic>)
              .map((e) => TuitionFeeBySubject.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pendingFees': pendingFees.map((e) => e.toJson()).toList(),
      'paidFees': paidFees.map((e) => e.toJson()).toList(),
      'subjectFees': subjectFees.map((e) => e.toJson()).toList(),
    };
  }
}
