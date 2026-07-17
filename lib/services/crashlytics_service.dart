// ================================================================
// services/crashlytics_service.dart — Firebase Crashlytics (بند 12)
// يسجّل الأخطاء تلقائياً في Production
// ================================================================
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../core/utils/app_logger.dart';
import '../core/errors/app_exception.dart';

class CrashlyticsService {
  static bool _initialized = false;

  // ── تهيئة — استدعِ في main() ──────────────────────────────────
  static Future<void> init() async {
    if (_initialized) return;

    // في Debug Mode: لا ترسل أخطاء لـ Crashlytics
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    // اعترض كل الأخطاء غير المعالجة في Flutter
    FlutterError.onError = (errorDetails) {
      AppLogger.error(
        'Flutter Error',
        exception: errorDetails.exception,
        stack: errorDetails.stack,
      );
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // اعترض أخطاء Dart الغير متزامنة
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.error('Platform Error', exception: error, stack: stack);
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    _initialized = true;
    AppLogger.info('CrashlyticsService: initialized (enabled: ${!kDebugMode})');
  }

  // ── تسجيل خطأ يدوياً ──────────────────────────────────────────
  static Future<void> recordError(
    Object error, {
    StackTrace? stack,
    bool fatal = false,
    String? reason,
  }) async {
    AppLogger.error(reason ?? 'Recorded error', exception: error, stack: stack);
    if (kDebugMode) return; // في Debug لا نرسل

    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  // ── تسجيل AppException ────────────────────────────────────────
  static Future<void> recordAppException(
    AppException e, {
    StackTrace? stack,
  }) async {
    await recordError(e, stack: stack, reason: e.message);
  }

  // ── تسجيل معلومات المستخدم (بدون بيانات مالية) ───────────────
  static Future<void> setUserInfo({
    required String uid,
    required String currency,
    required String language,
  }) async {
    if (kDebugMode) return;
    await FirebaseCrashlytics.instance.setUserIdentifier(uid);
    await FirebaseCrashlytics.instance.setCustomKey('currency', currency);
    await FirebaseCrashlytics.instance.setCustomKey('language', language);
  }

  // ── سجّل حدث مخصص (breadcrumb) ────────────────────────────────
  static Future<void> log(String message) async {
    AppLogger.debug('Crashlytics.log: $message');
    if (kDebugMode) return;
    await FirebaseCrashlytics.instance.log(message);
  }

  // ── اختبار (للتجربة فقط) ──────────────────────────────────────
  static Future<void> testCrash() async {
    if (!kDebugMode) return; // فقط في Debug
    AppLogger.warning('Testing Crashlytics crash...');
    FirebaseCrashlytics.instance.crash();
  }
}
