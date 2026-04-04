class PLOModel {
  final int studentId;
  final int ploId;
  final String ploName;
  final double ploScore;

  PLOModel({
    required this.studentId,
    required this.ploId,
    required this.ploName,
    required this.ploScore,
  });

  factory PLOModel.fromJson(Map<String, dynamic> json) {
    return PLOModel(
      studentId: (json['studentId'] as num?)?.toInt() ?? 0,
      ploId: (json['ploId'] as num?)?.toInt() ?? 0,
      ploName: json['ploName']?.toString() ?? '',
      ploScore: (json['ploScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
