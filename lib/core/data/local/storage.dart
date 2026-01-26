import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

import '../../../common/extensions/optional_x.dart';
import '../../../features/auth/data/model/user_model.dart';

class _Keys {
  static const lang = 'lang';
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const deviceId = 'device_id';
  static const pushToken = 'push_token';
  static const user = 'user';
  static const hintEmail = 'hint_email';

  // notification settings
  static const generalNotification = 'general_notification';
  static const personalNotification = 'personal_notification';
  static const queueNotification = 'queue_notification';
  static const remainTurn = 'remain_turn';
  static const examNotification = 'exam_notification';
  static const remindBefore = 'remind_before';
  static const scheduleNotifications = 'schedule_notifications';

  // chatbot
  static const chatBotConversationId = 'chat_bot_conversation_id';
}

class Storage {
  static late final SharedPreferences _prefs;
  static late final RxSharedPreferences _rxPrefs;

  static const _storage = FlutterSecureStorage();

  static setup() async {
    _prefs = await SharedPreferences.getInstance();

    /// A shared preference wrapper providing [Stream] for listening updates
    /// from shared preference by key
    _rxPrefs = RxSharedPreferences(
      _prefs,
      // disable logging when running in release mode.
      kReleaseMode ? null : const RxSharedPreferencesDefaultLogger(),
    );
  }

  static T? _get<T>(String key) => _prefs.get(key).asOrNull<T>();

  /// set value to shared preference by [key].
  /// If you want the updated value to be notified for stream subscriptions
  /// created by [RxSharedPreferences], please set [notify] as `true`
  static Future<void> _set<T>(String key, T? val, {bool notify = false}) {
    if (val == null) {
      _rxPrefs.remove(key);
      return _prefs.remove(key);
    }
    if (val is bool) {
      return notify ? _rxPrefs.setBool(key, val) : _prefs.setBool(key, val);
    }
    if (val is double) {
      return notify ? _rxPrefs.setDouble(key, val) : _prefs.setDouble(key, val);
    }
    if (val is int) {
      return notify ? _rxPrefs.setInt(key, val) : _prefs.setInt(key, val);
    }
    if (val is String) {
      return notify ? _rxPrefs.setString(key, val) : _prefs.setString(key, val);
    }
    if (val is List<String>) {
      return notify
          ? _rxPrefs.setStringList(key, val)
          : _prefs.setStringList(key, val);
    }
    throw Exception('Type not supported!');
  }

  static Future<String?> _getSecure(String key) => _storage.read(key: key);

  static Future<void> _setSecure(String key, String? val) =>
      _storage.write(key: key, value: val);

  static String? get lang => _get(_Keys.lang);

  static Future setLang(String? val) => _set(_Keys.lang, val);

  static UserModel? get user {
    final userString = _get<String>(_Keys.user);
    return _parseUser(userString);
  }

  static Stream<UserModel?> get userStream {
    return _rxPrefs
        .getStringStream(_Keys.user)
        .map((event) => _parseUser(event));
  }

  static UserModel? _parseUser(String? userString) {
    try {
      if (userString != null) {
        return UserModel.fromJson(json.decode(userString));
      }
    } catch (e) {
      // logger.e(e);
    }
    return null;
  }

  static Future<void> setUser(UserModel? val) {
    if (val == null) {
      return _set(_Keys.user, null);
    }
    return _set(_Keys.user, json.encode(val.toJson()));
  }

  static Future<String?> get accessToken => _getSecure(_Keys.accessToken);

  static Future setAccessToken(String? val) =>
      _setSecure(_Keys.accessToken, val);

  static Future<String?> get refreshToken => _getSecure(_Keys.accessToken);

  static Future setRefreshToken(String? val) =>
      _setSecure(_Keys.refreshToken, val);

  static Future setDeviceId(String? val) => _set(_Keys.deviceId, val);

  static String? get pushToken => _get(_Keys.pushToken);
  static Future setPushToken(String? val) => _set(_Keys.pushToken, val);

  // Save hint email for login with Microsoft
  static String? get hintEmail => _get(_Keys.hintEmail);
  static Future<void> setHintEmail(String? val) => _set(_Keys.hintEmail, val);

  static bool get generalNotification =>
      _get<bool>(_Keys.generalNotification) ?? true;
  static Future<void> setGeneralNotification(bool val) =>
      _set(_Keys.generalNotification, val, notify: true);

  static bool get myNotification =>
      _get<bool>(_Keys.personalNotification) ?? true;
  static Future<void> setMyNotification(bool val) =>
      _set(_Keys.personalNotification, val, notify: true);

  static bool get queueNotification =>
      _get<bool>(_Keys.queueNotification) ?? true;
  static Future<void> setQueueNotification(bool val) =>
      _set(_Keys.queueNotification, val, notify: true);

  static int get remainTurn => _get<int>(_Keys.remainTurn) ?? 3;
  static Future<void> setRemainTurn(int val) =>
      _set(_Keys.remainTurn, val, notify: true);

  static bool get examNotification =>
      _get<bool>(_Keys.examNotification) ?? true;
  static Future<void> setExamNotification(bool val) =>
      _set(_Keys.examNotification, val, notify: true);

  static int get remindBefore => _get<int>(_Keys.remindBefore) ?? 15;
  static Future<void> setRemindBefore(int val) =>
      _set(_Keys.remindBefore, val, notify: true);

  //Get stored schedule notifications
  static String? getScheduleNotifications() {
    final key = _Keys.scheduleNotifications;
    return _get<String>(key);
  }

  // Set schedule notifications
  static Future<void> setScheduleNotifications(String? val) {
    final key = _Keys.scheduleNotifications;
    return _set(key, val);
  }

  static String get chatBotConversationId =>
      _get<String>(_Keys.chatBotConversationId) ?? "";
  static Future<void> setChatBotConversationId(String val) =>
      _set(_Keys.chatBotConversationId, val, notify: true);

  static String getConversationIdByChatbot(String chatbotId) =>
      _get<String>("${_Keys.chatBotConversationId}__$chatbotId") ?? "";

  static Future<void> setConversationIdByChatbot(
    String chatbotId,
    String val,
  ) => _set("${_Keys.chatBotConversationId}__$chatbotId", val, notify: true);
}
