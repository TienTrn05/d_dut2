class TuitionFeeBySubject {
  final String subjectId;
  final String classId;
  final double credits;
  final bool classType;
  final String className;
  final double tuitionFee;
  final bool retake;

  TuitionFeeBySubject({
    required this.subjectId,
    required this.classId,
    required this.credits,
    required this.classType,
    required this.className,
    required this.tuitionFee,
    required this.retake,
  });

  factory TuitionFeeBySubject.fromJson(Map<String, dynamic> json) {
    return TuitionFeeBySubject(
      subjectId: json['subjectId'] ?? '',
      classId: json['classId'] ?? '',
      credits: _parseDouble(json['credits']),
      classType: json['classType'] == 1 || json['classType'] == true,
      className: json['className'] ?? '',
      tuitionFee: _parseDouble(json['tuitionFee']),
      retake: json['retake'] == 1 || json['retake'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'subjectId': subjectId,
    'classId': classId,
    'credits': credits,
    'classType': classType,
    'className': className,
    'tuitionFee': tuitionFee,
    'retake': retake,
  };

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
