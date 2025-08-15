import 'package:injectable/injectable.dart';

import '../../data/data_sources/remote_data_source/notification_service.dart';
import '../../data/models/notification.dart';

@injectable
class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository(this._notificationService);

  Future<void> registerFCMToken(String token, String FCMtoken) async {
    try {
      await _notificationService.registerFCMToken(token, FCMtoken);
    } catch (e) {
      throw Exception('Failed to register FCM token: $e');
    }
  }

  Future<List<Notification>> fetchMyNotifications(String token,
      {int limit = 5, String? lastVisible}) async {
    try {
      final notifications = await _notificationService.getMyNotifications(token,
          limit: limit, lastVisible: lastVisible);
      return notifications;
    } catch (e) {
      throw Exception('Failed to load my notifications: $e');
    }
  }

  Future<List<Notification>> fetchGeneralNotifications(String token,
      {int limit = 5, String? lastVisible}) async {
    try {
      final notifications = await _notificationService.getGeneralNotifications(token,
          limit: limit, lastVisible: lastVisible);
      return notifications;
    } catch (e) {
      throw Exception('Failed to load general notifications: $e');
    }
  }
}
