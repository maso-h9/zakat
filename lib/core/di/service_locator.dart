import 'package:get_it/get_it.dart';
import '../../data/datasources/shared_prefs_storage.dart';
import '../../data/datasources/firestore_gold_price_data_source.dart';
import '../../data/datasources/firestore_sync_data_source.dart';
import '../../data/datasources/hive_cache_data_source.dart';
import '../../data/datasources/gemini_api_client.dart';
import '../../data/repositories_impl/settings_repository_impl.dart';
import '../../data/repositories_impl/zakat_repository_impl.dart';
import '../../data/repositories_impl/gold_price_repository_impl.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../data/repositories_impl/ai_chat_repository_impl.dart';
import '../../data/repositories_impl/currency_repository_impl.dart';
import '../../data/repositories_impl/notification_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/zakat_repository.dart';
import '../../domain/repositories/gold_price_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../../domain/repositories/currency_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/calculate_zakat.dart';
import '../../domain/usecases/send_ai_message.dart';
import '../../domain/usecases/get_gold_price.dart';
import '../../domain/usecases/manage_wealth.dart';
import '../../domain/usecases/get_currencies.dart';
import '../../presentation/features/ai_chat/ai_chat_view_model.dart';
import '../../presentation/features/calculator/calculator_view_model.dart';
import '../../presentation/features/settings/settings_view_model.dart';
import '../../presentation/features/home/home_view_model.dart';
import '../../services/notification_service.dart';
import '../../core/utils/app_logger.dart';

final sl = GetIt.instance;

/// Initialize all dependencies. Call once at app startup.
Future<void> initServiceLocator() async {
  // ── Data Sources ──────────────────────────────────────────
  final storage = SharedPrefsStorage();
  final firestoreGoldPrice = FirestoreGoldPriceDataSource();
  final firestoreSync = FirestoreSyncDataSource();
  final hiveCache = HiveCacheDataSource();

  try {
    await hiveCache.init();
  } catch (e) {
    AppLogger.warning('DI: Hive init failed: $e');
  }

  // ── Gemini API Key ────────────────────────────────────────
  final geminiApiKey = _readApiKey();
  AppLogger.info(
    'DI: gemini_api_key ${geminiApiKey.isEmpty ? "EMPTY" : "loaded (${geminiApiKey.length} chars)"}',
  );

  // ── Register Data Sources ─────────────────────────────────
  sl.registerSingleton<SharedPrefsStorage>(storage);
  sl.registerSingleton<FirestoreGoldPriceDataSource>(firestoreGoldPrice);
  sl.registerSingleton<FirestoreSyncDataSource>(firestoreSync);
  sl.registerSingleton<HiveCacheDataSource>(hiveCache);
  sl.registerSingleton<GeminiApiClient>(GeminiApiClient(apiKey: geminiApiKey));

  // ── Register Repositories ─────────────────────────────────
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(storage),
  );
  sl.registerLazySingleton<ZakatRepository>(
    () => ZakatRepositoryImpl(storage),
  );
  sl.registerLazySingleton<GoldPriceRepository>(
    () => GoldPriceRepositoryImpl(firestoreGoldPrice, hiveCache),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(firestoreSync),
  );
  sl.registerLazySingleton<AiChatRepository>(
    () => AiChatRepositoryImpl(sl<GeminiApiClient>()),
  );
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(NotificationService()),
  );

  // ── Register Use Cases ────────────────────────────────────
  sl.registerLazySingleton(() => CalculateZakatUseCase());
  sl.registerLazySingleton(() => SendAiMessageUseCase(sl<AiChatRepository>()));
  sl.registerLazySingleton(() => GetGoldPriceUseCase(sl<GoldPriceRepository>()));
  sl.registerLazySingleton(() => SaveWealthUseCase(sl<ZakatRepository>()));
  sl.registerLazySingleton(() => LoadWealthUseCase(sl<ZakatRepository>()));
  sl.registerLazySingleton(() => SaveZakatHistoryUseCase(sl<ZakatRepository>()));
  sl.registerLazySingleton(() => LoadZakatHistoryUseCase(sl<ZakatRepository>()));
  sl.registerLazySingleton(() => AddZakatRecordUseCase(sl<ZakatRepository>()));
  sl.registerLazySingleton(() => GetAvailableCurrenciesUseCase(sl<CurrencyRepository>()));

  // ── Register ViewModels ───────────────────────────────────
  sl.registerFactory(() => AiChatViewModel(sl<SendAiMessageUseCase>()));
  sl.registerFactory(() => CalculatorViewModel(sl<CalculateZakatUseCase>()));
  sl.registerFactory(() => SettingsViewModel(sl<SettingsRepository>()));
  sl.registerFactory(() => HomeViewModel(sl<GetGoldPriceUseCase>()));

  AppLogger.info('DI: Service locator initialized');
}

String _readApiKey() {
  try {
    const key = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (key.isNotEmpty) return key;
  } catch (_) {}
  return '';
}
