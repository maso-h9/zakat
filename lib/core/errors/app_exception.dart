// ================================================================
// core/errors/app_exception.dart — نظام الأخطاء الموحّد (بند 5)
// ================================================================

/// الاستثناء الأساسي للتطبيق
class AppException implements Exception {
  final String message;
  final String? arabicMessage;
  final Object? cause;

  const AppException(this.message, {this.arabicMessage, this.cause});

  String get userMessage => arabicMessage ?? message;

  @override
  String toString() =>
      'AppException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

// ── أنواع الأخطاء ──────────────────────────────────────────────

class NetworkException extends AppException {
  const NetworkException({String? cause})
      : super(
          'Network error',
          arabicMessage:
              'تعذّر الاتصال بالإنترنت. تأكد من اتصالك وحاول مجدداً.',
          cause: cause,
        );
}

class TimeoutException extends AppException {
  const TimeoutException({String? cause})
      : super(
          'Request timed out',
          arabicMessage: 'انتهت مهلة الطلب. حاول مجدداً.',
          cause: cause,
        );
}

class FirebaseAppException extends AppException {
  FirebaseAppException(String code, {Object? cause})
      : super(
          'Firebase error: $code',
          arabicMessage: _arabicFirebaseMessage(code),
          cause: cause,
        );

  static String _arabicFirebaseMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'ليس لديك صلاحية الوصول لهذه البيانات.';
      case 'not-found':
        return 'البيانات المطلوبة غير موجودة.';
      case 'unavailable':
        return 'الخدمة غير متاحة حالياً. حاول لاحقاً.';
      case 'unauthenticated':
        return 'يجب تسجيل الدخول أولاً.';
      case 'already-exists':
        return 'البيانات موجودة بالفعل.';
      case 'resource-exhausted':
        return 'تجاوزت الحد المسموح. حاول لاحقاً.';
      default:
        return 'حدث خطأ في قاعدة البيانات ($code).';
    }
  }
}

class ApiException extends AppException {
  final int? statusCode;

  const ApiException(String endpoint, {this.statusCode, Object? cause})
      : super(
          'API error on $endpoint (status: $statusCode)',
          arabicMessage: statusCode == 429
              ? 'تجاوزت حد الطلبات. حاول بعد قليل.'
              : statusCode == 401
                  ? 'مفتاح API غير صحيح أو منتهي الصلاحية.'
                  : statusCode == 503
                      ? 'الخدمة غير متاحة حالياً.'
                      : 'تعذّر جلب البيانات من الخادم.',
          cause: cause,
        );
}

class CacheException extends AppException {
  const CacheException({String detail = '', Object? cause})
      : super(
          'Cache error: $detail',
          arabicMessage: 'تعذّر قراءة البيانات المحفوظة محلياً.',
          cause: cause,
        );
}

class AuthException extends AppException {
  AuthException(String code, {Object? cause})
      : super(
          'Auth error: $code',
          arabicMessage: _arabicAuthMessage(code),
          cause: cause,
        );

  static String _arabicAuthMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد الإلكتروني.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل.';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة.';
      case 'too-many-requests':
        return 'محاولات كثيرة. حاول لاحقاً.';
      case 'network-request-failed':
        return 'تعذّر الاتصال. تحقق من الإنترنت.';
      default:
        return 'حدث خطأ في المصادقة ($code).';
    }
  }
}

class UnknownException extends AppException {
  const UnknownException({Object? cause})
      : super(
          'Unknown error',
          arabicMessage: 'حدث خطأ غير متوقع. حاول مجدداً.',
          cause: cause,
        );
}

// ── دالة مساعدة: حوّل أي exception لـ AppException ─────────────
AppException toAppException(Object e) {
  if (e is AppException) return e;
  final msg = e.toString();
  if (msg.contains('SocketException') ||
      msg.contains('NetworkException') ||
      msg.contains('Failed host lookup')) {
    return NetworkException(cause: msg);
  }
  if (msg.contains('TimeoutException') || msg.contains('timed out')) {
    return TimeoutException(cause: msg);
  }
  if (msg.contains('FirebaseException')) {
    final code = RegExp(r'\[([^\]]+)\]').firstMatch(msg)?.group(1) ?? 'unknown';
    return FirebaseAppException(code, cause: e);
  }
  return UnknownException(cause: e);
}
