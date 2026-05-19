import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../network/api_client.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await LocalNotificationService.showNotification(message);
  debugPrint('[FCM] Background: ${message.notification?.title}');
}

class FcmService {
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission (iOS)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages → show local notification
    FirebaseMessaging.onMessage.listen(LocalNotificationService.showNotification);

    // App opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  static void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] Opened from: ${message.notification?.title}');
  }

  static Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('[FCM] getToken error: $e');
      return null;
    }
  }

  static Future<void> deleteToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('[FCM] deleteToken error: $e');
    }
  }

  static Future<void> registerToken(ApiClient api) async {
    final token = await getToken();
    if (token == null) return;

    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      await api.post(Api.registerFcmToken, data: {
        'token': token,
        'platform': platform,
      });
      debugPrint('[FCM] Token registered ✅');
    } catch (e) {
      debugPrint('[FCM] Register error (non-fatal): $e');
    }
  }

  static Future<void> unregisterToken(ApiClient api) async {
    final token = await getToken();
    if (token == null) return;

    try {
      await api.delete(Api.unregisterFcmToken, data: {'token': token});
      debugPrint('[FCM] Token unregistered ✅');
    } catch (e) {
      debugPrint('[FCM] Unregister error (non-fatal): $e');
    }
  }
}
