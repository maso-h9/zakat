import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../core/utils/app_logger.dart';
import '../core/errors/app_exception.dart';

class CrashlyticsService {
  static bool _initialized = false;
  static String _currentScreen = 'unknown';

  static Future<void> init() async {
    if (_initialized) return;

    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    final previousHandler = FlutterError.onError;
    FlutterError.onError = (errorDetails) {
      AppLogger.error(
        'Flutter Error',
        exception: errorDetails.exception,
        stack: errorDetails.stack,
      );
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      previousHandler?.call(errorDetails);
    };

    final previousPlatformHandler = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.error('Platform Error', exception: error, stack: stack);
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return previousPlatformHandler?.call(error, stack) ?? true;
    };

    _initialized = true;
    AppLogger.info('CrashlyticsService: initialized (enabled: ${!kDebugMode})');
  }

  static Future<void> recordError(
    Object error, {
    StackTrace? stack,
    bool fatal = false,
    String? reason,
    String? screen,
  }) async {
    AppLogger.error(reason ?? 'Recorded error', exception: error, stack: stack);
    if (kDebugMode) return;

    await FirebaseCrashlytics.instance.setCustomKey(
      'screen',
      screen ?? _currentScreen,
    );
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  static Future<void> recordAppException(
    AppException e, {
    StackTrace? stack,
    String? screen,
    String? operation,
  }) async {
    final screenName = screen ?? _currentScreen;
    final operationName = operation ?? 'unknown';

    AppLogger.error(
      'AppException: ${e.message} [screen: $screenName, op: $operationName]',
      exception: e,
      stack: stack,
    );

    if (kDebugMode) return;

    await FirebaseCrashlytics.instance.setCustomKey('screen', screenName);
    await FirebaseCrashlytics.instance
        .setCustomKey('operation', operationName);
    await FirebaseCrashlytics.instance.setCustomKey(
      'exception_type',
      e.runtimeType.toString(),
    );
    await FirebaseCrashlytics.instance.recordError(
      e,
      stack,
      reason: '${e.message} [screen: $screenName, op: $operationName]',
      fatal: false,
    );
  }

  static void setCurrentScreen(String screen) {
    _currentScreen = screen;
    AppLogger.debug('Screen: $screen');
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.setCustomKey('screen', screen);
    }
  }

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

  static Future<void> setCustomKey(String key, dynamic value) async {
    if (kDebugMode) return;
    await FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  static Future<void> log(String message) async {
    AppLogger.crashlyticsLog(message);
    if (kDebugMode) return;
    await FirebaseCrashlytics.instance.log(message);
  }

  static Future<void> testCrash() async {
    if (!kDebugMode) return;
    AppLogger.warning('Testing Crashlytics crash...');
    FirebaseCrashlytics.instance.crash();
  }
}
