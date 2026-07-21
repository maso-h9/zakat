import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../data/datasources/gemini_api_client.dart';
import '../data/datasources/shared_prefs_storage.dart';
import '../data/datasources/firestore_gold_price_data_source.dart';
import '../data/datasources/firestore_sync_data_source.dart';
import '../data/datasources/hive_cache_data_source.dart';
import '../data/repositories_impl/ai_chat_repository_impl.dart';
import '../data/repositories_impl/settings_repository_impl.dart';
import '../data/repositories_impl/zakat_repository_impl.dart';
import '../data/repositories_impl/gold_price_repository_impl.dart';
import '../data/repositories_impl/auth_repository_impl.dart';
import '../domain/usecases/send_ai_message.dart';
import '../domain/usecases/calculate_zakat.dart';
import '../presentation/features/ai_chat/ai_chat_view_model.dart';
import '../presentation/features/calculator/calculator_view_model.dart';
import '../presentation/features/settings/settings_view_model.dart';
import '../core/utils/app_logger.dart';

class DependencyProvider {
  static List<SingleChildWidget> get providers {
    // ── Data Sources ────────────────────────────────────────
    final storage = SharedPrefsStorage();
    final firestoreGoldPrice = FirestoreGoldPriceDataSource();
    final firestoreSync = FirestoreSyncDataSource();
    final hiveCache = HiveCacheDataSource();

    // ── Initialize Hive (non-blocking) ──────────────────────
    _initHive(hiveCache);

    // ── Gemini API Key ──────────────────────────────────────
    final geminiApiKey = _readApiKey();
    AppLogger.info(
        'DI: gemini_api_key ${geminiApiKey.isEmpty ? "EMPTY" : "loaded (${geminiApiKey.length} chars)"}');

    // ── API Clients ─────────────────────────────────────────
    final geminiClient = GeminiApiClient(apiKey: geminiApiKey);

    // ── Repository Implementations ──────────────────────────
    final aiRepo = AiChatRepositoryImpl(geminiClient);
    final settingsRepo = SettingsRepositoryImpl(storage);
    ZakatRepositoryImpl(storage);
    GoldPriceRepositoryImpl(firestoreGoldPrice, hiveCache);
    AuthRepositoryImpl(firestoreSync);

    // ── Use Cases ───────────────────────────────────────────
    final sendAiMessageUseCase = SendAiMessageUseCase(aiRepo);
    final calculateZakatUseCase = CalculateZakatUseCase();

    return [
      // ── View Models ───────────────────────────────────────
      ChangeNotifierProvider<AiChatViewModel>(
        create: (_) => AiChatViewModel(sendAiMessageUseCase),
      ),
      ChangeNotifierProvider<CalculatorViewModel>(
        create: (_) => CalculatorViewModel(calculateZakatUseCase),
      ),
      ChangeNotifierProvider<SettingsViewModel>(
        create: (_) => SettingsViewModel(settingsRepo)..loadSettings(),
      ),
    ];
  }

  static Future<void> _initHive(HiveCacheDataSource cache) async {
    try {
      await cache.init();
    } catch (e) {
      AppLogger.warning('DI: Hive init failed: $e');
    }
  }

  static String _readApiKey() {
    try {
      final key = FirebaseRemoteConfig.instance.getString('gemini_api_key');
      if (key.isNotEmpty) return key;
    } catch (e) {
      AppLogger.warning('DI: Remote Config read failed: $e');
    }

    try {
      const envKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
      if (envKey.isNotEmpty) return envKey;
    } catch (_) {}

    return '';
  }
}
