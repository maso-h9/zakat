import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'zakat_channel';
  static const String _channelName = 'تذكيرات الزكاة';
  static const String _channelDesc = 'إشعارات تذكير بمواعيد الزكاة والصدقة';

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createChannel();
  }

  Future<void> _createChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onNotificationTap(NotificationResponse response) {
    // يمكن إضافة navigation هنا لاحقاً
  }

  Future<bool> requestPermission() async {
    final result = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return result ?? false;
  }

  // إشعار فوري
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _plugin.show(id, title, body, details);
  }

  // تذكير سنوي بحولان الحول (يوم الزكاة)
  Future<void> scheduleZakatAnnual({
    required DateTime nisabDate,
  }) async {
    final zakatDate = nisabDate.add(const Duration(days: 354)); // سنة هجرية
    if (zakatDate.isBefore(DateTime.now())) return;

    final tz.TZDateTime scheduled = tz.TZDateTime.from(zakatDate, tz.local);

    await _plugin.zonedSchedule(
      1001,
      '🌙 حال الحول على نصابك',
      'لقد مرّت سنة كاملة على بلوغ نصابك — حان وقت إخراج الزكاة',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // تذكير قبل حولان الحول بأسبوع
  Future<void> scheduleZakatReminder({
    required DateTime nisabDate,
  }) async {
    final reminderDate =
        nisabDate.add(const Duration(days: 347)); // أسبوع قبل الحول
    if (reminderDate.isBefore(DateTime.now())) return;

    final tz.TZDateTime scheduled = tz.TZDateTime.from(reminderDate, tz.local);

    await _plugin.zonedSchedule(
      1002,
      '⏰ تذكير: أسبوع على حولان الحول',
      'بعد 7 أيام يحول الحول على نصابك — استعد لإخراج زكاتك',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // تذكير يومي في رمضان (الساعة 9 صباحاً)
  Future<void> scheduleRamadanDailyReminder() async {
    await _plugin.zonedSchedule(
      2001,
      '🌙 تذكير رمضان',
      'لا تنسَ صدقة اليوم — الصدقة في رمضان بسبعين ضعفاً',
      _nextInstanceOfTime(9, 0),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.defaultImportance,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // تذكير زكاة الفطر (آخر 3 أيام رمضان)
  Future<void> scheduleFitrReminder({required DateTime eidDate}) async {
    final reminderDate = eidDate.subtract(const Duration(days: 3));
    if (reminderDate.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      3001,
      '🕌 تذكير زكاة الفطر',
      'تبقّى 3 أيام على العيد — أخرج زكاة الفطر قبل صلاة العيد',
      tz.TZDateTime.from(reminderDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<List<PendingNotificationRequest>> getPending() async {
    return await _plugin.pendingNotificationRequests();
  }
}
