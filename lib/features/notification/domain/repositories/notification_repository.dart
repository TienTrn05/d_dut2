import 'package:injectable/injectable.dart';

import '../../data/data_sources/remote_data_source/notification_service.dart';
import '../../data/models/notification.dart';

@injectable
class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository(this._notificationService);

  Future<List<Notification>> fetchMyNotifications(
    String token,
  ) async {
    try {
      final notifications = await _notificationService.getMyNotifications(
        token
      );
      return notifications;
    } catch (e) {
      throw Exception('Failed to load my notifications: $e');
    }
  }
}