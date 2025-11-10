import 'tuition_fee_summary.dart';

class TuitionFee {
  final TuitionFeeSummary tuitionFees;
  final String academicYearCode;

  TuitionFee({required this.tuitionFees, required this.academicYearCode});

  factory TuitionFee.fromJson(Map<String, dynamic> json) {
    return TuitionFee(
      tuitionFees: TuitionFeeSummary.fromJson(json['tuitionFees']),
      academicYearCode: json['academicYearCode'],
    );
  }
}
