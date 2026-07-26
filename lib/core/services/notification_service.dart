// services/notification_service.dart

import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:e_dut/features/auth/data/model/role_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:device_info_plus/device_info_plus.dart';

import '../../common/utils/getit_utils.dart';
import '../../features/app/app_router.dart';
import '../../features/schedule/util/schedule_noti.dart';
import '../data/local/storage.dart';
import '/common/utils/logger.dart';
import '/firebase_options.dart';
import 'auto_redirect_service.dart';

// Handler cho background messages phải là một top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

class NotificationService {
  // Singleton pattern để đảm bảo chỉ có một instance của service
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      _flutterLocalNotificationsPlugin;

  late AndroidNotificationChannel _channel;
  late AndroidNotificationChannel _scheduleChannel;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // channel cho nhắc nhở lịch học
    _scheduleChannel = AndroidNotificationChannel(
      'class_reminder_channel', // ID phải khớp với ID trong AndroidNotificationDetails
      'Nhắc nhở lịch học',
      description: 'Thông báo nhắc nhở trước giờ học.',
      importance: Importance.max, // Đặt mức độ quan trọng cao nhất
    );
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_scheduleChannel);

    // 1. Khởi tạo Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _firebaseMessaging = FirebaseMessaging.instance;

    // 2. Khởi tạo Timezone cho việc lên lịch local
    tz.initializeTimeZones();

    // 3. Cài đặt cho Remote Notifications (từ code có sẵn của bạn)
    _channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Cài đặt chung cho flutter_local_notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTapped,
    );

    await _requestPermissions();

    _isInitialized = true;
    logger.i("Notification Service Initialized");
  }

  Future<void> _requestPermissions() async {
    // 1. Xin quyền post notification (cho Android 13+)
    // Flutter_local_notifications đã làm điều này, nhưng gọi lại để chắc chắn
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidImplementation?.requestNotificationsPermission();

      // 2. Xin quyền đặt báo thức chính xác (cho Android 12+)
      // Đây là phần quan trọng nhất để sửa lỗi của bạn
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 31) {
        // Android 12 (S)
        await androidImplementation?.requestExactAlarmsPermission();
      }
    } else if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  // --- PHẦN XỬ LÝ REMOTE NOTIFICATION (Push từ server) ---

  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      logger.i('Firebase Messaging Token: $token');
      return token;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  void registerMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen(onRemoteNotificationTapped);

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        onRemoteNotificationTapped(message);
      }
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    logger.i("Received a foreground message: ${message.notification?.title}");
    await showRemoteNotification(message);

    try {
      final isTeacher = Storage.user?.role.name == RoleModel.roleTeacher;
      final accessToken = await Storage.accessToken;

      if (accessToken != null) {
        await ScheduleNoti.setupScheduleNotifications(isTeacher, accessToken);
      }
    } catch (e) {
      logger.e(
        "[Notification Service] Error when setup schedule notifications: $e",
        exception: e,
      );
    }
  }

  Future<void> showRemoteNotification(RemoteMessage message) async {
    String? imageUrl = message.notification?.android?.imageUrl;
    String? title = message.notification?.title ?? message.data['title'];
    String? body = message.notification?.body ?? message.data['body'];
    bool isGeneral =
        message.data['isGeneral']?.toString().toLowerCase() == 'true';

    if (title == null && body == null) {
      logger.i('Thông báo remote rỗng, không hiển thị');
      return;
    }

    AndroidNotificationDetails androidDetails;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final bigPicture = await _getBigPictureStyleInformation(
        imageUrl,
        title,
        body,
      );
      androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        icon: '@mipmap/launcher_icon',
        importance: _channel.importance,
        priority: Priority.high,
        styleInformation: bigPicture,
        largeIcon: bigPicture?.largeIcon,
      );
    } else {
      androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        icon: '@mipmap/launcher_icon',
        importance: _channel.importance,
        priority: Priority.high,
      );
    }

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );
    _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      notificationDetails,
      payload:
          isGeneral == true
              ? 'RedirectToNotificationScreenGeneralTab'
              : 'RedirectToNotificationScreen',
    );
  }

  // --- PHẦN XỬ LÝ LOCAL NOTIFICATION (Lên lịch từ app) ---

  Future<void> scheduleClassNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    logger.i("Scheduling notification ID $id for $scheduledTime");
    var d = tz.TZDateTime.from(scheduledTime, tz.local);
    var n = tz.TZDateTime.now(tz.local);
    if (d.isBefore(n)) {
      logger.w(
        "Scheduled time is in the past, notification will not be scheduled.",
      );
      return;
    }
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _scheduleChannel.id, // Tạo channel riêng cho nhắc nhở
          _scheduleChannel.name,
          channelDescription: _scheduleChannel.description,
          importance: Importance.max,
          icon: '@mipmap/launcher_icon',
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    logger.i('All notifications is canceled');
  }

  // --- CÁC HÀM TIỆN ÍCH và CALLBACK ---

  Future<BigPictureStyleInformation?> _getBigPictureStyleInformation(
    String imageUrl,
    String? title,
    String? body,
  ) async {
    try {
      var response = await http.get(Uri.parse(imageUrl));
      final imageBytes = response.bodyBytes;
      AndroidBitmap<Object> androidBitmap = ByteArrayAndroidBitmap(imageBytes);
      return BigPictureStyleInformation(
        androidBitmap,
        contentTitle: title,
        summaryText: body,
        htmlFormatContent: true,
        htmlFormatContentTitle: true,
      );
    } catch (e) {
      logger.e("Error fetching image for notification: $e");
      return null;
    }
  }

  void onRemoteNotificationTapped(RemoteMessage message) {
    try {
      logger.i("Notification tapped with payload: ${message.data}");

      bool isGeneral =
          message.data['isGeneral']?.toString().toLowerCase() == 'true';

      AutoRedirectService.pendingPayload =
          isGeneral == true
              ? 'RedirectToNotificationScreenGeneralTab'
              : 'RedirectToNotificationScreen';

      getIt<AppRouter>().replaceAll([const RootRoute()]);
    } catch (e, stack) {
      logger.e(
        "Error handling notification tap: $e",
        exception: e,
        stackTrace: stack,
      );
      AutoRedirectService.pendingPayload = message.data['payload'];
    }
  }

  void onNotificationTapped(NotificationResponse response) {
    try {
      logger.i("Notification tapped with payload: ${response.payload}");
      AutoRedirectService.pendingPayload = response.payload;

      getIt<AppRouter>().replaceAll([const RootRoute()]);
    } catch (e, stack) {
      logger.e(
        "Error handling notification tap: $e",
        exception: e,
        stackTrace: stack,
      );
      AutoRedirectService.pendingPayload = response.payload;
    }
  }

  // Đăng ký topic
  Future<void> subscribeToTopic(String topic) async {
    final safeTopic = sanitizeTopic(topic);
    try {
      await _firebaseMessaging.subscribeToTopic(safeTopic);
      logger.i("Subscribed to topic: $safeTopic");
    } catch (e) {
      logger.e("Error when subscribing to topic: $safeTopic — $e");
    }
  }

  // Hủy đăng ký topic
  Future<void> unsubscribeFromTopic(String topic) async {
    final safeTopic = sanitizeTopic(topic);
    try {
      await _firebaseMessaging.unsubscribeFromTopic(safeTopic);
      logger.i("Unsubscribed from topic: $safeTopic");
    } catch (e) {
      logger.e("Error when unsubscribing to topic: $safeTopic — $e");
    }
  }

  /// Chuẩn hóa tên topic trước khi đăng ký/hủy đăng ký
  String sanitizeTopic(String topic) {
    // Thay mọi ký tự @ thành dấu gạch dưới
    return topic.replaceAll('@', '_');
  }

  Future<bool> areNotificationsAllowed() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      final granted = await androidImplementation?.areNotificationsEnabled();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iosImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();
      final settings = await iosImplementation?.checkPermissions();
      return settings?.isEnabled ?? false;
    }
    return false;
  }

  Future<void> openAppSettings() async {
    if (Platform.isAndroid) {
      await AppSettings.openAppSettings();
    } else if (Platform.isIOS) {
      await AppSettings.openAppSettings();
    }
  }
}
