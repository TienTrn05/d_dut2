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

  Future<void> registerFCMToken(String token, String FCMtoken) async {
    try {
      final response =
          await _apiClient.dio.post("$_url/api/notifications/register-token",
              data: {"token": FCMtoken},
              options: Options(headers: {
                "Authorization": "Bearer $token",
              }));
      if (response.statusCode != 200) {
        throw Exception("Failed to register FCM token: ${response.data}");
      }
    } catch (e) {
      logger.e("Error registering FCM token: $e");
      rethrow;
    }
  }

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

  Future<List<Notification>> getGeneralNotifications(String token,
      {int limit = 5, String? lastVisible}) async {
    try {
      final response = await _apiClient.dio.get(
          !lastVisible.isNullOrEmpty
              ? "$_url/api/notifications/general?limit=$limit&lastVisible=$lastVisible"
              : "$_url/api/notifications/general?limit=$limit",
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
      logger.e("Error fetching general notifications: $e");
      rethrow;
    }
  }

  Future<void> sendNotificationToMultiUsers(
    String token, {
    required List<String> userIds,
    required String title,
    required String body,
    String? link,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        "$_url/api/notifications/send-multi-notifications",
        data: {
          "userIds": userIds,
          "title": title,
          "body": body,
          if (link != null) "link": link,
        },
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to send notifications: ${response.data}");
      }
    } catch (e) {
      logger.e("Error sending notifications: $e");
      rethrow;
    }
  }
}
