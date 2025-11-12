class PaidTuitionFee {
  final String studentId;
  final String academicYearCode;
  final double amountPaid;
  final String? note;
  final DateTime? paymentDate;
  final String? receiptNumber;

  PaidTuitionFee({
    required this.studentId,
    required this.academicYearCode,
    required this.amountPaid,
    this.note,
    this.paymentDate,
    this.receiptNumber,
  });

  factory PaidTuitionFee.fromJson(Map<String, dynamic> json) {
    return PaidTuitionFee(
      studentId: json['studentId'] ?? '',
      academicYearCode: json['academicYearCode'] ?? '',
      amountPaid: _parseDouble(json['amountPaid']),
      note: json['note'],
      paymentDate: _parseDate(json['paymentDate']),
      receiptNumber: json['receiptNumber'],
    );
  }

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'academicYearCode': academicYearCode,
    'amountPaid': amountPaid,
    'note': note,
    'paymentDate': paymentDate?.toIso8601String(),
    'receiptNumber': receiptNumber,
  };

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    try {
      return DateTime.tryParse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
