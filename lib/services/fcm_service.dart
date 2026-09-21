// ================================================================
// services/fcm_service.dart — Firebase Cloud Messaging (بند 24)
// إشعارات Push من السيرفر (GitHub Actions) + محلية
// ================================================================
// ignore: depend_on_referenced_packages
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/utils/app_logger.dart';

// ── Handler في الخلفية (يجب أن يكون top-level) ──────────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('FCM Background: ${message.messageId}');
  // لا نحتاج تهيئة Firebase هنا — مهيّأ بالفعل في main()
}

class FcmService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // ── تهيئة ─────────────────────────────────────────────────────
  static Future<void> init() async {
    if (_initialized) return;

    // طلب إذن الإشعارات
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    AppLogger.info('FCM Permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      AppLogger.warning('FCM: المستخدم رفض الإشعارات');
      return;
    }

    // تهيئة الإشعارات المحلية (لعرض FCM وهو Foreground)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // إنشاء قناة Android
    const channel = AndroidNotificationChannel(
      'zakat_channel',
      'تنبيهات الزكاة',
      description: 'إشعارات تحديث الأسعار وموعد الزكاة',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Handler للـ Background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handler للـ Foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handler عند الضغط على إشعار (تطبيق مغلق أو في الخلفية)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    // FCM Topic للتحديثات
    await _subscribeToTopics();

    // احفظ FCM Token
    final token = await _messaging.getToken();
    AppLogger.info('FCM Token: ${token?.substring(0, 20)}...');

    _initialized = true;
  }

  // ── الاشتراك في Topics ────────────────────────────────────────
  static Future<void> _subscribeToTopics() async {
    // كل المستخدمين يتلقون تحديثات الأسعار
    await _messaging.subscribeToTopic('price_updates');
    // إشعار موعد الزكاة (اختياري)
    await _messaging.subscribeToTopic('zakat_reminders');
    AppLogger.info('FCM: Subscribed to topics');
  }

  // ── إشعار وهو Foreground ─────────────────────────────────────
  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    AppLogger.info('FCM Foreground: ${message.notification?.title}');

    final notification = message.notification;
    final android = message.notification?.android;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'zakat_channel',
          'تنبيهات الزكاة',
          channelDescription: 'إشعارات تحديث الأسعار وموعد الزكاة',
          importance: Importance.high,
          priority: Priority.high,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── عند الضغط على إشعار ──────────────────────────────────────
  static void _onMessageOpened(RemoteMessage message) {
    AppLogger.info('FCM Opened: ${message.data}');
    // يمكن إضافة navigation هنا مستقبلاً
    // مثال: إذا data['type'] == 'price_update' → افتح شاشة الإعدادات
  }

  static void _onNotificationTapped(NotificationResponse response) {
    AppLogger.info('Local notification tapped: ${response.payload}');
  }

  // ── إلغاء الاشتراك (عند تعطيل الإشعارات من الإعدادات) ────────
  static Future<void> unsubscribeAll() async {
    await _messaging.unsubscribeFromTopic('price_updates');
    await _messaging.unsubscribeFromTopic('zakat_reminders');
    AppLogger.info('FCM: Unsubscribed from all topics');
  }

  // ── حالة الإذن ────────────────────────────────────────────────
  static Future<bool> hasPermission() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }
}
