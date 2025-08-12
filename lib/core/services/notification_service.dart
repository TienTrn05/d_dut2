
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../../firebase_options.dart';

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
bool isFlutterLocalNotificationsInitialized = false;

Future<void> _ensureNotificationSetup() async {
  if (isFlutterLocalNotificationsInitialized) return;

  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  isFlutterLocalNotificationsInitialized = true;
}

Future<Uint8List> getImageBytes(String? imageUrl) async {
  var response = await http.get(Uri.parse(imageUrl!));
  return response.bodyBytes;
}

Future<void> _showNotification(RemoteMessage message) async {
  if (!kIsWeb) {
    print('showing notification');
    String? imageUrl = message.notification?.android?.imageUrl;
    String? title = message.notification?.title ?? message.data['title'];
    String? body = message.notification?.body ?? message.data['body'];

    // Kiểm tra dữ liệu thông báo
    if ((title == null || title.isEmpty || title == '') &&
        (body == null || body.isEmpty || title == '')) {
      print('Thông báo rỗng, không hiển thị');
      return;
    }

    AndroidNotificationDetails androidDetails;
    DarwinNotificationDetails iOSDetails;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      var res = await getImageBytes(imageUrl);
      AndroidBitmap<Object> androidBitmap =
          ByteArrayAndroidBitmap.fromBase64String(base64Encode(res));
      BigPictureStyleInformation bigPictureStyleInformation =
          BigPictureStyleInformation(
        androidBitmap,
        contentTitle: title,
        summaryText: body,
        htmlFormatContent: true,
        htmlFormatContentTitle: true,
        hideExpandedLargeIcon: true,
      );

      androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: '@mipmap/launcher_icon',
        onlyAlertOnce: true,
        importance: channel.importance,
        priority: Priority.high,
        showWhen: true,
        largeIcon: androidBitmap,
        styleInformation: bigPictureStyleInformation,
      );
    } else {
      androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: '@mipmap/launcher_icon',
        onlyAlertOnce: true,
        importance: channel.importance,
        priority: Priority.high,
        showWhen: true,
      );
    }

    iOSDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: null,
      sound: 'default',
    );

    var notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);
    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      notificationDetails,
    );
  }
}

class FirebaseAPI with ChangeNotifier {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await _ensureNotificationSetup();
    await _firebaseMessaging.requestPermission(
        alert: true, badge: true, sound: true);
    String? token = await getToken();
    registerMessageHandlers();
    return token;
  }

  void registerMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_foregroundMessageHandler);
  }

  Future<void> _foregroundMessageHandler(RemoteMessage message) async {
    await _ensureNotificationSetup();
    _showNotification(message);
  }

  Future<String?> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('Firebase Messaging Token: $token');
    } else {
      print('Failed to get Firebase Messaging Token');
    }
    return token;
  }
}
