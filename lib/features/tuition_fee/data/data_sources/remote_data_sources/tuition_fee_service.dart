import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '/core/services/api_client.dart';
import '/common/utils/logger.dart';

import '../../models/pending_tuition_fee.dart';
import '../../models/paid_tuition_fee.dart';
import '../../models/tuition_fee_by_subject.dart';

@injectable
class TuitionFeeService {
  final String _url;
  final ApiClient _apiClient;

  TuitionFeeService(@Named('tuitionFeeAPIUrl') String url)
    : _url = url,
      _apiClient = ApiClient(url);

  /// 🧾 Danh sách học phí cần nộp
  Future<List<PendingTuitionFee>> getPendingTuitionFees(
    String authToken,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/tuation_fees/pending",
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );

      final data = response.data;

      if (data['isSuccess'] == true) {
        final List<dynamic> raw = data['data'];
        return raw.map((e) => PendingTuitionFee.fromJson(e)).toList();
      } else {
        throw Exception(
          "Failed to load pending tuition fees: ${data['message']}",
        );
      }
    } catch (e) {
      logger.e("Error fetching pending tuition fees $e");
      rethrow;
    }
  }

  /// 💰 Danh sách học phí đã nộp
  Future<List<PaidTuitionFee>> getPaidTuitionFees(
    String authToken,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/tuation_fees/paid",
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );

      final data = response.data;

      if (data['isSuccess'] == true) {
        final List<dynamic> raw = data['data'];
        return raw.map((e) => PaidTuitionFee.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load paid tuition fees: ${data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching paid tuition fees $e");
      rethrow;
    }
  }

  /// 📚 Học phí theo môn học
  Future<List<TuitionFeeBySubject>> getTuitionFeesBySubject(
    String authToken,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/tuation_fees/by-subject",
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );

      final data = response.data;

      if (data['isSuccess'] == true) {
        final List<dynamic> raw = data['data'];
        return raw.map((e) => TuitionFeeBySubject.fromJson(e)).toList();
      } else {
        throw Exception(
          "Failed to load tuition fees by subject: ${data['message']}",
        );
      }
    } catch (e) {
      logger.e("Error fetching tuition fees by subject $e");
      rethrow;
    }
  }
}
