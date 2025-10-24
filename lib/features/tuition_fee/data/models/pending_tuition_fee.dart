class PendingTuitionFee {
  final String studentId;
  final String academicYearCode;
  final double amount;
  final String? note;
  final bool visible;
  final int paymentRound;

  PendingTuitionFee({
    required this.studentId,
    required this.academicYearCode,
    required this.amount,
    this.note,
    required this.visible,
    required this.paymentRound,
  });

  factory PendingTuitionFee.fromJson(Map<String, dynamic> json) {
    return PendingTuitionFee(
      studentId: json['studentId'] ?? '',
      academicYearCode: json['academicYearCode'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      note: json['note'],
      visible: json['visible'] == 1 || json['visible'] == true,
      paymentRound: json['paymentRound'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'academicYearCode': academicYearCode,
        'amount': amount,
        'note': note,
        'visible': visible,
        'paymentRound': paymentRound,
      };
}
