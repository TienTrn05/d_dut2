import 'dart:io';
import 'academic_api_client.dart';

class SubjectResult {
  final String semesterCode; // "Kỳ học"
  final String subjectCode; // (nếu có)
  final String classCode; // "Mã lớp học phần"
  final int? credits; // "Số tín chỉ"
  final double? score10; // "Thang 10"
  final String? scoreChar; // "Tổng kết" (chữ)
  final double? score4; // "Thang 4"
  final String? subjectTitle; // "Tên học phần"
  final String? formula; // "Công thức điểm"
  final List<String> detailLines; // "Chi tiết điểm" (List<String>)

  const SubjectResult({
    required this.semesterCode,
    required this.subjectCode,
    required this.classCode,
    this.credits,
    this.score10,
    this.scoreChar,
    this.score4,
    this.subjectTitle,
    this.formula,
    this.detailLines = const [],
  });

  factory SubjectResult.fromJson(Map<String, dynamic> j) => SubjectResult(
        semesterCode: (j['semesterCode'] ?? '') as String,
        subjectCode: (j['subjectCode'] ?? '') as String,
        classCode: (j['classCode'] ?? '') as String,
        credits: (j['credits'] as num?)?.toInt(),
        score10: (j['score10'] as num?)?.toDouble(),
        scoreChar: j['scoreChar'] as String?,
        score4: (j['score4'] as num?)?.toDouble(),
        subjectTitle: j['subjectTitle'] as String?,
        formula: j['formula'] as String?,
        detailLines: (j['detailLines'] as List?)
                ?.map((e) => e?.toString() ?? '')
                .where((s) => s.trim().isNotEmpty)
                .toList() ??
            const [],
      );
}

class ResultsRepository {
  ResultsRepository(this._api);
  final AcademicApiClient _api;

  // ---- helpers ----
  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse('$v');
  }

  String _toStr(dynamic v) => v?.toString() ?? '';

  Map<String, dynamic> _normalizeItem(Map raw) {
    // "Kỳ học", "Mã lớp học phần", "Số tín chỉ",
    // "Thang 10", "Thang 4", "Tổng kết", "Tên học phần",
    // "Công thức điểm", "Chi tiết điểm"
    final semesterCode = raw['semesterCode'] ?? raw['Kỳ học'];
    final classCode = raw['classCode'] ?? raw['Mã lớp học phần'];
    final credits = raw['credits'] ?? raw['Số tín chỉ'];
    final score10 = raw['score10'] ?? raw['Thang 10'];
    final score4 = raw['score4'] ?? raw['Thang 4'];
    final scoreChar = raw['scoreChar'] ?? raw['Tổng kết'];
    final subjectTitle = raw['subjectTitle'] ?? raw['Tên học phần'];
    final formula = raw['formula'] ?? raw['Công thức điểm'];

    // "Chi tiết điểm" có thể là List<String>
    final rawDetail = raw['detailLines'] ?? raw['Chi tiết điểm'];
    List<String> detailLines = const [];
    if (rawDetail is List) {
      detailLines = rawDetail
          .map((e) => e?.toString() ?? '')
          .where((s) => s.trim().isNotEmpty)
          .toList();
    }

    return {
      'semesterCode': _toStr(semesterCode),
      'subjectCode':
          _toStr(raw['subjectCode']), // có thể rỗng nếu API không trả
      'classCode': _toStr(classCode),
      'credits': _toInt(credits),
      'score10': _toDouble(score10),
      'score4': _toDouble(score4),
      'scoreChar': scoreChar == null ? null : _toStr(scoreChar),
      'subjectTitle': subjectTitle == null ? null : _toStr(subjectTitle),
      'formula': formula == null ? null : _toStr(formula),
      'detailLines': detailLines,
    };
  }

  // Lấy danh sách kết quả học tập theo studentId
  Future<List<SubjectResult>> fetchResults(String studentId) async {
    final id = studentId.trim();
    if (id.isEmpty) {
      throw ArgumentError('studentId is required and must not be empty');
    }

    try {
      final list = await _api.getList(
        '/results',
        query: {'studentId': id},
      );

      // Chuẩn hoá từng phần tử và map sang model
      return list
          .whereType<Map>() // chỉ nhận object
          .map((raw) => _normalizeItem(raw))
          .map((m) => SubjectResult.fromJson(
                Map<String, dynamic>.from(m),
              ))
          .toList();
    } on HttpException {
      rethrow;
    } catch (e) {
      // Gói lỗi lại cho dễ debug
      throw HttpException('Failed to fetch results for $id: $e');
    }
  }
}
