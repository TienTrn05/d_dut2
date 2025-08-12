import 'package:dio/dio.dart';
import 'package:e_dut/common/extensions/optional_x.dart';
import 'package:injectable/injectable.dart';

import '/core/services/api_client.dart';
import '/common/utils/logger.dart';

import '../../models/notification.dart';

@injectable
class NotificationService {
  final String _url;
  final ApiClient _apiClient;

  NotificationService(@Named('pushNotificationAPIUrl') String url)
      : _url = url,
        _apiClient = ApiClient(url);

  Future<List<Notification>> getMyNotifications(String token,
      {int limit = 5, String? lastVisible}) async {
    try {
      final response = await _apiClient.dio.get(
          !lastVisible.isNullOrEmpty
              ? "$_url/api/notifications?limit=$limit&lastVisible=$lastVisible"
              : "$_url/api/notifications?limit=$limit",
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      if (response.statusCode == 200) {
        final data = response.data['data']['notifications'];

        final List<Notification> notifications = (data as List)
            .map((notification) => Notification.fromJson(notification))
            .toList();
        return notifications;
      } else {
        throw Exception(
            "Failed to load notifications: ${response.data['message']}");
      }
    } catch (e) {
      logger.e("Error fetching my notifications: $e");
      rethrow;
    }
  }
}
