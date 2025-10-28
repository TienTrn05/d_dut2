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
      amountPaid: (json['amountPaid'] as num).toDouble(),
      note: json['note'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.tryParse(json['paymentDate'])
          : null,
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
}
