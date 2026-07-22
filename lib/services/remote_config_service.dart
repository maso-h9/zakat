// ================================================================
// services/remote_config_service.dart — تخزين آمن لمفاتيح API
// Firebase Remote Config: المفتاح على السيرفر، لا في الكود
// ================================================================
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../core/utils/app_logger.dart';

class RemoteConfigService {
  static final _rc = FirebaseRemoteConfig.instance;
  static bool _initialized = false;

  // ── القيم الافتراضية ─────────────────────────────────────────
  // فقط مفتاح Gemini — GOLDAPI و METALS_API في GitHub Secrets (ليس هنا)
  static const Map<String, dynamic> _defaults = {
    'gemini_api_key': '', // يُعبَّأ من Firebase Console → Remote Config
  };

  // ── تهيئة ─────────────────────────────────────────────────────
  static Future<void> init() async {
    if (_initialized) return;
    try {
      await _rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _rc.setDefaults(_defaults);
      await _rc.fetchAndActivate();
      _initialized = true;
      AppLogger.info('RemoteConfig: initialized');
    } catch (e) {
      // فشل صامت — سيستخدم القيم الافتراضية
      AppLogger.warning('RemoteConfig: failed, using defaults ($e)');
      _initialized = true;
    }
  }

  // ── قراءة المفاتيح ────────────────────────────────────────────
  static String get geminiApiKey {
    final key = _rc.getString('gemini_api_key');
    AppLogger.debug(
        'RemoteConfig: gemini_api_key ${key.isEmpty ? "EMPTY" : "loaded"}');
    return key;
  }

  // ── تحديث يدوي ───────────────────────────────────────────────
  static Future<void> refresh() async {
    try {
      await _rc.fetchAndActivate();
      AppLogger.info('RemoteConfig: refreshed');
    } catch (e) {
      AppLogger.warning('RemoteConfig: refresh failed ($e)');
    }
  }
}
