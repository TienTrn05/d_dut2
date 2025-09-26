class StatsModel {
  // Overall
  final double? gpa4; // GPA thang 4 (kỳ mới nhất)
  final double? gpa10; // fallback nếu server có
  final int totalCredits; // tổng TC đăng ký (giữ để tương thích)
  final int? totalAccumCredits; // HPTichLuy (kỳ mới nhất)
  final double? avgConduct; // Điểm rèn luyện trung bình
  final String? stage; // Năm học

  final List<String> semesters;
  final List<double> gpaPerSemester; // DiemTBTL 4.0 theo kỳ
  final List<double> conductPerSemester; // DiemRL 0-100 theo kỳ
  final List<int> creditsPerSemester; // HPDangky theo kỳ

  /// Breakdown theo kỳ
  final List<SemesterStat> bySemester;

  StatsModel({
    this.gpa4,
    this.gpa10,
    required this.totalCredits,
    this.totalAccumCredits,
    this.avgConduct,
    this.stage,
    this.semesters = const [],
    this.gpaPerSemester = const [],
    this.conductPerSemester = const [],
    this.creditsPerSemester = const [],
    this.bySemester = const [],
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    double? _d(v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
    int? _i(v) =>
        v == null ? null : (v is num ? v.toInt() : int.tryParse('$v'));
    String? _s(v) => v == null ? null : '$v';

    List<String> _strList(v) =>
        (v is List ? v.map((e) => '$e').toList() : const <String>[]);
    List<double> _doubleList(v) =>
        (v is List)
            ? v
                .map((e) => (e is num ? e.toDouble() : double.tryParse('$e')))
                .whereType<double>()
                .toList()
            : const <double>[];
    List<int> _intList(v) =>
        (v is List)
            ? v
                .map((e) => (e is num ? e.toInt() : int.tryParse('$e')))
                .whereType<int>()
                .toList()
            : const <int>[];

    // Mảng cho biểu đồ
    final semesters = _strList(json['semesters']);
    final gpaPerSem = _doubleList(json['gpaPerSemester']);
    final conductPerSem = _doubleList(json['conductPerSemester']);
    final creditsPerSem = _intList(json['creditsPerSemester']);

    // Tổng quan
    final ov = (json['overall'] as Map?) ?? const {};
    final gpa4 = _d(ov['gpa4']) ?? _d(ov['gpa10']);
    final gpa10 = _d(ov['gpa10']);
    final totalAccumCredits = _i(ov['totalAccumCredits']);
    final totalCredits = _i(ov['totalCredits'] ?? ov['totalAccumCredits']) ?? 0;
    final avgConduct = _d(ov['avgConduct']);
    final stage = _s(ov['stage'] ?? ov['studyStage']);

    final n = [
      semesters.length,
      gpaPerSem.length,
      creditsPerSem.length,
      conductPerSem.length,
    ].where((x) => x > 0).fold<int>(1 << 30, (a, b) => a < b ? a : b);

    final bySemester = <SemesterStat>[];
    for (var i = 0; i < (n == (1 << 30) ? 0 : n); i++) {
      bySemester.add(
        SemesterStat(
          semester: i < semesters.length ? semesters[i] : null,
          gpa4: i < gpaPerSem.length ? gpaPerSem[i] : null,
          credits: i < creditsPerSem.length ? creditsPerSem[i] : null,
          conduct: i < conductPerSem.length ? conductPerSem[i] : null,
        ),
      );
    }

    return StatsModel(
      gpa4: gpa4,
      gpa10: gpa10,
      totalCredits: totalCredits,
      totalAccumCredits: totalAccumCredits,
      avgConduct: avgConduct,
      stage: stage,
      semesters: semesters,
      gpaPerSemester: gpaPerSem,
      conductPerSemester: conductPerSem,
      creditsPerSemester: creditsPerSem,
      bySemester: bySemester,
    );
  }
}

class SemesterStat {
  final String? semester;
  final double? gpa10;
  final double? gpa4; // GPA thang 4
  final int? credits; // Tín chỉ đăng ký
  final double? conduct; // ĐRL 0-100

  SemesterStat({
    this.semester,
    this.gpa10,
    this.gpa4,
    this.credits,
    this.conduct,
  });

  factory SemesterStat.fromJson(Map<String, dynamic> json) {
    double? _d(v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
    int? _i(v) =>
        v == null ? null : (v is num ? v.toInt() : int.tryParse('$v'));

    return SemesterStat(
      semester: json['semester'] ?? json['HocKy'] ?? json['term'],
      gpa10: _d(json['gpa10'] ?? json['GPA10']),
      gpa4: _d(json['gpa4'] ?? json['GPA4']),
      credits: _i(json['credits'] ?? json['TinChi']),
      conduct: _d(json['conduct'] ?? json['DiemRL']),
    );
  }
}
