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
      amount: _parseDouble(json['amount']),
      note: json['note'],
      visible: json['visible'] == 1 || json['visible'] == true,
      paymentRound: _parseInt(json['paymentRound']),
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

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
