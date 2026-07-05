// ================================================================
// auth_service.dart — تسجيل الدخول الكامل
// lib/services/auth_service.dart
// ================================================================
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;
  static bool get isSignedIn => currentUser != null;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── إيميل: إنشاء حساب ───────────────────────────────────────
  static Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (displayName != null && displayName.isNotEmpty) {
        await cred.user?.updateDisplayName(displayName);
      }
      return AuthResult.success(cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(arabicError(e.code));
    }
  }

  // ─── إيميل: تسجيل دخول ───────────────────────────────────────
  static Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return AuthResult.success(cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(arabicError(e.code));
    }
  }

  // ─── إيميل: نسيت كلمة المرور ─────────────────────────────────
  static Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null,
          message: 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(arabicError(e.code));
    }
  }

  // ─── Google ───────────────────────────────────────────────────
  // ⚠️ يحتاج SHA-1 مضاف في Firebase Console
  // شغّل: cd android && ./gradlew signingReport
  // انسخ SHA-1 وأضفه في: Firebase Console → Project Settings → Android App
  static Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.error('تم إلغاء تسجيل الدخول');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      return AuthResult.success(cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(arabicError(e.code));
    } catch (e) {
      return AuthResult.error(
          'فشل تسجيل الدخول بـ Google. تأكد من إضافة SHA-1 في Firebase.');
    }
  }

  // ─── رقم الهاتف: إرسال OTP ───────────────────────────────────
  // ⚠️ يحتاج تفعيل Phone Auth في Firebase Console → Authentication → Sign-in method
  static Future<void> sendPhoneOtp({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerified,
    required Function(FirebaseAuthException) onFailed,
    required Function(String, int?) onCodeSent,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerified,
      verificationFailed: onFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 60),
    );
  }

  // ─── رقم الهاتف: تأكيد OTP ───────────────────────────────────
  static Future<AuthResult> verifyPhoneOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);
      final cred = await _auth.signInWithCredential(credential);
      return AuthResult.success(cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(arabicError(e.code));
    }
  }

  // ─── تسجيل خروج ──────────────────────────────────────────────
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── حذف الحساب ──────────────────────────────────────────────
  static Future<AuthResult> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      return AuthResult.success(null, message: 'تم حذف الحساب');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(arabicError(e.code));
    }
  }

  // ─── ترجمة الأخطاء — public الآن ─────────────────────────────
  static String arabicError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة — استخدم 6 أحرف على الأقل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'too-many-requests':
        return 'محاولات كثيرة — انتظر قليلاً وأعد المحاولة';
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح';
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صحيح — استخدم الصيغة الدولية مثل +218912345678';
      case 'session-expired':
        return 'انتهت صلاحية رمز التحقق — أعد إرساله';
      case 'requires-recent-login':
        return 'يجب تسجيل الدخول مجدداً لتنفيذ هذه العملية';
      case 'operation-not-allowed':
        return 'طريقة تسجيل الدخول غير مفعّلة في Firebase Console';
      default:
        return 'حدث خطأ — حاول مجدداً ($code)';
    }
  }

  // ─── دالة عامة لتسجيل الدخول بـ Credential ───────────────────
  static Future<AuthResult> signInWithCredential(
      AuthCredential credential) async {
    try {
      final cred = await _auth.signInWithCredential(credential);
      return AuthResult.success(cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(arabicError(e.code));
    }
  }
}

class AuthResult {
  final User? user;
  final String? error;
  final String? message;
  bool get isSuccess => error == null;

  const AuthResult._({this.user, this.error, this.message});
  factory AuthResult.success(User? user, {String? message}) =>
      AuthResult._(user: user, message: message);
  factory AuthResult.error(String error) => AuthResult._(error: error);
}
