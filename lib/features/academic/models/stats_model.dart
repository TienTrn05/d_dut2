class StatsModel {
  final double? gpa4; // GPA thang 4 (kỳ mới nhất)
  final double? gpa10;
  final num totalCredits; // tổng TC đăng ký
  final num? totalAccumCredits; // HPTichLuy (kỳ mới nhất)
  final double? avgConduct; // Điểm rèn luyện trung bình
  final String? stage; // Năm học

  final List<String> semesters;
  final List<double> gpaPerSemester; // DiemTBTL 4.0 theo kỳ
  final List<double> conductPerSemester; // DiemRL 0-100 theo kỳ
  final List<num> creditsPerSemester; // HPDangky theo kỳ

  /// Thống kê theo kỳ
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
    List<num> _numList(v) =>
        (v is List)
            ? v
                .map((e) => (e is num ? e : num.tryParse('$e')))
                .whereType<num>()
                .toList()
            : const <num>[];

    // Mảng cho biểu đồ
    final semesters = _strList(json['semesters']);
    final gpaPerSem = _doubleList(json['gpaPerSemester']);
    final conductPerSem = _doubleList(json['conductPerSemester']);
    final creditsPerSem = _numList(json['creditsPerSemester']);

    // Tổng quan
    final ov = (json['overall'] as Map?) ?? const {};
    final gpa4 = _d(ov['gpa4']) ?? _d(ov['gpa10']);
    final gpa10 = _d(ov['gpa10']);
    num? _n(v) =>
        v == null ? null : (v is num ? v : num.tryParse('$v'));
    final totalAccumCredits = _n(ov['totalAccumCredits']);
    final totalCredits = _n(ov['totalCredits'] ?? ov['totalAccumCredits']) ?? 0;
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
  final num? credits; // Tín chỉ đăng ký
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
    num? _n(v) =>
        v == null ? null : (v is num ? v : num.tryParse('$v'));

    return SemesterStat(
      semester: json['semester'] ?? json['HocKy'] ?? json['term'],
      gpa10: _d(json['gpa10'] ?? json['GPA10']),
      gpa4: _d(json['gpa4'] ?? json['GPA4']),
      credits: _n(json['credits'] ?? json['TinChi']),
      conduct: _d(json['conduct'] ?? json['DiemRL']),
    );
  }
}
