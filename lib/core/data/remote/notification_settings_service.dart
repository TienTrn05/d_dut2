import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '/core/services/api_client.dart';
import '/common/utils/logger.dart';
import '/common/utils/app_environment.dart';

@injectable
class NotificationSettingsService {
  final String _url;
  final ApiClient _apiClient;

  NotificationSettingsService(@Named('notificationSettingsAPIUrl') String url)
    : _url = url,
      _apiClient = ApiClient(url);

  Future<void> setRemainTurn(String token, int remainTurn) async {
    try {
      final response = await _apiClient.dio.post(
        "$_url/api/notifications/queue/remain-turn",
        data: {"remainTurn": remainTurn},
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "x-api-key": AppEnvironment.pushNotificationsAPIKey,
          },
        ),
      );
      if (response.statusCode != 200) {
        throw Exception(
          "NotificationSettingsService:Failed to set RemainTurn: ${response.data}",
        );
      }
    } catch (e) {
      logger.e("NotificationSettingsService:Error setting RemainTurn: $e");
      rethrow;
    }
  }
}
