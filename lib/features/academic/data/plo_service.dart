import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/plo_model.dart';
import '/core/services/api_client.dart';
import '/common/utils/logger.dart';

@injectable
class PLOService {
  final String _url;
  final ApiClient _apiClient;

  PLOService(@Named('ploAPIUrl') String url)
    : _url = url,
      _apiClient = ApiClient(url);

  Future<List<PLOModel>> getPLO(String token) async {
    try {
      final response = await _apiClient.dio.get(
        "$_url/api/results/student-plo-scores-by-code",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200) {
        final data = response.data;

        final List<PLOModel> plo =
            (data as List)
                .map((notification) => PLOModel.fromJson(notification))
                .toList();
        return plo;
      } else {
        throw Exception("Failed to load PLO: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching general PLO: $e");
      rethrow;
    }
  }
}
