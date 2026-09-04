import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String channelId = 'alerta_plus_channel';
  static const String channelName = 'ALERTA+';
  static const String historyKey = 'notification_history';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  FirebaseMessaging? _messaging;
  bool _firebaseAvailable = false;

  String? fcmToken;

  Future<void> initialize({required bool firebaseAvailable}) async {
    await _initializeLocalNotifications();

    _firebaseAvailable = firebaseAvailable;
    if (!_firebaseAvailable) return;

    _messaging = FirebaseMessaging.instance;

    await requestPermission();
    await getFCMToken();

    _configureForegroundMessages();
    _configureNotificationInteractions();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'Notificações do aplicativo ALERTA+',
      importance: Importance.high,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<NotificationSettings?> requestPermission() async {
    final messaging = _messaging;
    if (messaging == null) return null;

    return messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getFCMToken() async {
    final messaging = _messaging;
    if (messaging == null) return null;

    try {
      fcmToken = await messaging.getToken();
      return fcmToken;
    } catch (exception) {
      debugPrint('Erro ao obter token FCM: $exception');
      return null;
    }
  }

  void _configureForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title =
          message.notification?.title ??
          message.data['title']?.toString() ??
          'Nova notificação';
      final body =
          message.notification?.body ?? message.data['body']?.toString() ?? '';
      final type = message.data['type']?.toString() ?? 'mensagem';
      final id =
          message.data['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();

      await showNotification(
        title: title,
        message: body,
        id: id,
        type: type,
      );
    });
  }

  Future<void> showNotification({
    required String title,
    required String message,
    required String id,
    required String type,
  }) async {
    final notification = NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      dateTime: DateTime.now(),
    );

    await saveNotification(notification);

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Notificações do aplicativo ALERTA+',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id.hashCode,
      title,
      message,
      details,
      payload: jsonEncode({
        'id': id,
        'title': title,
        'message': message,
        'type': type,
      }),
    );
  }

  void _configureNotificationInteractions() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notificação pressionada: ${message.data}');
    });
  }

  Future<Map<String, dynamic>?> getInitialMessageData() async {
    final messaging = _messaging;
    if (messaging == null) return null;

    final message = await messaging.getInitialMessage();
    return message?.data;
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      debugPrint('Notificação local pressionada: ${response.payload}');
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(historyKey) ?? <String>[];
    final notifications = <NotificationModel>[];

    for (final item in items) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map) {
          notifications.add(
            NotificationModel.fromMap(Map<String, dynamic>.from(decoded)),
          );
        }
      } on FormatException catch (exception) {
        debugPrint('Histórico de notificação inválido: $exception');
      }
    }

    return notifications;
  }

  Future<void> saveNotification(NotificationModel notification) async {
    final notifications = await getNotifications();
    notifications.removeWhere((item) => item.id == notification.id);
    notifications.insert(0, notification);

    await _saveNotifications(notifications);
  }

  Future<void> markAsRead(String id) async {
    final notifications = await getNotifications();

    for (final notification in notifications) {
      if (notification.id == id) {
        notification.isRead = true;
      }
    }

    await _saveNotifications(notifications);
  }

  Future<void> deleteNotification(String id) async {
    final notifications = await getNotifications();
    notifications.removeWhere((item) => item.id == id);

    await _saveNotifications(notifications);
  }

  Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(historyKey);
  }

  Future<void> _saveNotifications(
    List<NotificationModel> notifications,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final items = notifications.map((item) => jsonEncode(item.toMap())).toList();

    await prefs.setStringList(historyKey, items);
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Mensagem recebida em segundo plano: ${message.data}');
}
