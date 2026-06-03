import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../navigation/deep_link_helper.dart';

final _plugin = FlutterLocalNotificationsPlugin();

class LocalNotificationService {
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onTap,
    );
  }

  static void _onTap(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null) return;
    try {
      final data = Map<String, String>.from(jsonDecode(raw) as Map);
      final link = parseNotificationPayload(data);
      if (link != null) {
        pendingDeepLinkNotifier.value = link;
        debugPrint('[NOTIF] Deep-link: $link');
      }
    } catch (e) {
      debugPrint('[NOTIF] Payload parse error: $e');
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      'bloom_channel',
      'Bloom Notifications',
      channelDescription: 'Notifikasi dari Bloom',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
    );
  }
}
