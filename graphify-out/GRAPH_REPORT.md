# Graph Report - .  (2026-07-22)

## Corpus Check
- 272 files · ~167,921 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2251 nodes · 2714 edges · 112 communities (104 shown, 8 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 8 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 49|Community 49]]
- [[_COMMUNITY_Community 50|Community 50]]
- [[_COMMUNITY_Community 51|Community 51]]
- [[_COMMUNITY_Community 52|Community 52]]
- [[_COMMUNITY_Community 53|Community 53]]
- [[_COMMUNITY_Community 54|Community 54]]
- [[_COMMUNITY_Community 55|Community 55]]
- [[_COMMUNITY_Community 56|Community 56]]
- [[_COMMUNITY_Community 57|Community 57]]
- [[_COMMUNITY_Community 58|Community 58]]
- [[_COMMUNITY_Community 59|Community 59]]
- [[_COMMUNITY_Community 60|Community 60]]
- [[_COMMUNITY_Community 61|Community 61]]
- [[_COMMUNITY_Community 62|Community 62]]
- [[_COMMUNITY_Community 63|Community 63]]
- [[_COMMUNITY_Community 64|Community 64]]
- [[_COMMUNITY_Community 65|Community 65]]
- [[_COMMUNITY_Community 66|Community 66]]
- [[_COMMUNITY_Community 67|Community 67]]
- [[_COMMUNITY_Community 68|Community 68]]
- [[_COMMUNITY_Community 69|Community 69]]
- [[_COMMUNITY_Community 70|Community 70]]
- [[_COMMUNITY_Community 71|Community 71]]
- [[_COMMUNITY_Community 72|Community 72]]
- [[_COMMUNITY_Community 73|Community 73]]
- [[_COMMUNITY_Community 74|Community 74]]
- [[_COMMUNITY_Community 75|Community 75]]
- [[_COMMUNITY_Community 76|Community 76]]
- [[_COMMUNITY_Community 77|Community 77]]
- [[_COMMUNITY_Community 78|Community 78]]
- [[_COMMUNITY_Community 79|Community 79]]
- [[_COMMUNITY_Community 80|Community 80]]
- [[_COMMUNITY_Community 81|Community 81]]
- [[_COMMUNITY_Community 82|Community 82]]
- [[_COMMUNITY_Community 83|Community 83]]
- [[_COMMUNITY_Community 84|Community 84]]
- [[_COMMUNITY_Community 85|Community 85]]
- [[_COMMUNITY_Community 86|Community 86]]
- [[_COMMUNITY_Community 87|Community 87]]
- [[_COMMUNITY_Community 88|Community 88]]
- [[_COMMUNITY_Community 89|Community 89]]
- [[_COMMUNITY_Community 90|Community 90]]
- [[_COMMUNITY_Community 91|Community 91]]
- [[_COMMUNITY_Community 92|Community 92]]
- [[_COMMUNITY_Community 93|Community 93]]
- [[_COMMUNITY_Community 94|Community 94]]
- [[_COMMUNITY_Community 95|Community 95]]
- [[_COMMUNITY_Community 96|Community 96]]
- [[_COMMUNITY_Community 97|Community 97]]
- [[_COMMUNITY_Community 98|Community 98]]
- [[_COMMUNITY_Community 99|Community 99]]
- [[_COMMUNITY_Community 100|Community 100]]
- [[_COMMUNITY_Community 101|Community 101]]

## God Nodes (most connected - your core abstractions)
1. `_` - 386 edges
2. `_` - 32 edges
3. `skills` - 12 edges
4. `AppException` - 11 edges
5. `Create()` - 10 edges
6. `MessageHandler()` - 10 edges
7. `AiChatViewModel` - 9 edges
8. `WndProc()` - 9 edges
9. `DataState` - 8 edges
10. `_MyApplication` - 7 edges

## Surprising Connections (you probably didn't know these)
- `FakeSettingsRepository` --implements--> `SettingsRepository`  [EXTRACTED]
  test/presentation/settings_view_model_test.dart → lib/domain/repositories/settings_repository.dart
- `MockGeminiApiClient` --implements--> `GeminiApiClient`  [EXTRACTED]
  test/data/repositories/ai_chat_repository_impl_test.dart → lib/data/datasources/gemini_api_client.dart
- `MockAiChatRepository` --implements--> `AiChatRepository`  [EXTRACTED]
  test/data/gemini_integration_test.dart → lib/domain/repositories/ai_chat_repository.dart
- `MockAiChatRepository` --implements--> `AiChatRepository`  [EXTRACTED]
  test/domain/usecases/send_ai_message_test.dart → lib/domain/repositories/ai_chat_repository.dart
- `MockSendAiMessageUseCase` --implements--> `SendAiMessageUseCase`  [EXTRACTED]
  test/presentation/ai_chat/ai_chat_view_model_test.dart → lib/domain/usecases/send_ai_message.dart

## Import Cycles
- None detected.

## Communities (112 total, 8 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.01
Nodes (378): _, aboutApp, aboutDescription, accountSummary, ahadith, aiAssistant, aiAssistantTitle, aiPlaceholder (+370 more)

### Community 1 - "Community 1"
Cohesion: 0.02
Nodes (84): CountrySource?, double amount,, Locale, addZakatRecord, calcNisabFromGramPrice, calcNisabFromOz, cloudSyncEnabled, currencies (+76 more)

### Community 2 - "Community 2"
Cohesion: 0.05
Nodes (48): main, MockSendAiMessageUseCase, mockUseCase, viewModel, bool get, client, main, main (+40 more)

### Community 3 - "Community 3"
Cohesion: 0.04
Nodes (55): static const Color, static const LinearGradient, static List, static ThemeData get, _buildDarkRamadanTheme, _buildDarkTheme, _buildLightTheme, _buildRamadanTheme (+47 more)

### Community 4 - "Community 4"
Cohesion: 0.04
Nodes (52): activeMethod, activeValue, _box, _boxName, _collection, compare, countryCode, countryCodeForCurrency (+44 more)

### Community 5 - "Community 5"
Cohesion: 0.06
Nodes (42): DartProject, RegisterPlugins(), PluginRegistry, Point, RECT, MessageHandler(), OnCreate(), Create() (+34 more)

### Community 6 - "Community 6"
Cohesion: 0.05
Nodes (47): ../datasources/shared_prefs_storage.dart, getCountrySource, loadAll, loadCloudSync, loadCurrency, loadDarkMode, loadFitrPaid, loadGoldPrice (+39 more)

### Community 7 - "Community 7"
Cohesion: 0.04
Nodes (48): package:google_sign_in/google_sign_in.dart, _, arabicError, _auth, AuthResult, AuthService, authStateChanges, currentUser (+40 more)

### Community 8 - "Community 8"
Cohesion: 0.06
Nodes (42): Color, ../data/zakat_data.dart, HadithModel, IconData, ../l10n/app_localizations.dart, login_screen.dart, package:fl_chart/fl_chart.dart, package:provider/provider.dart (+34 more)

### Community 9 - "Community 9"
Cohesion: 0.06
Nodes (45): ApiException, AppException, _arabicAuthMessage, _arabicFirebaseMessage, arabicMessage, AuthException, CacheException, cause (+37 more)

### Community 10 - "Community 10"
Cohesion: 0.05
Nodes (42): clearAll, _getPrefs, _keyCloudSync, _keyCurrency, _keyCurrencySymbol, _keyCustomNisab, _keyDarkMode, _keyFitrPaid (+34 more)

### Community 11 - "Community 11"
Cohesion: 0.05
Nodes (37): DateTime, AiMessage, copyWith, createdAt, fromMap, isError, isUser, main (+29 more)

### Community 12 - "Community 12"
Cohesion: 0.05
Nodes (37): addZakatRecord, amount, code, currencies, CurrencyModel, currencySymbol, date, debtsOwed (+29 more)

### Community 13 - "Community 13"
Cohesion: 0.07
Nodes (35): calculator_screen.dart, content_screens.dart, madhabs_screen.dart, MaterialPageRoute, package:zakat_app/screens/secondary_screens.dart, ../presentation/features/ai_chat/ai_chat_screen.dart, ramadan_screen.dart, build (+27 more)

### Community 14 - "Community 14"
Cohesion: 0.07
Nodes (33): _MessageBubble, Animation, AnimationController, ZakatApp, ../models/zakat_provider.dart, _MessageBubble, AhadithScreen, MasarifScreen (+25 more)

### Community 15 - "Community 15"
Cohesion: 0.06
Nodes (32): ConnectivityStatus get, dart:async, DateTime? get, ../entities/user_data.dart, AuthRepository, authStateChanges, isSignedIn, signInAnonymously (+24 more)

### Community 16 - "Community 16"
Cohesion: 0.06
Nodes (33): _box, _boxName, clearCache, _col, convert, _doc, _estimateFromOz, _fallback (+25 more)

### Community 17 - "Community 17"
Cohesion: 0.06
Nodes (31): apiTimeout, AppConstants, appName, appNameAr, geminiBaseUrl, geminiModel, goldNisabGrams, hijriYearDays (+23 more)

### Community 18 - "Community 18"
Cohesion: 0.06
Nodes (29): copyWith, empty, formattedTime, GoldPriceResult, isLive, pricePerGram, silverPricePerGram, source (+21 more)

### Community 19 - "Community 19"
Cohesion: 0.07
Nodes (29): age, _box, _boxName, cachedAt, CacheEntry, CacheManager, clear, data (+21 more)

### Community 20 - "Community 20"
Cohesion: 0.07
Nodes (28): double?, package:zakat_app/domain/repositories/settings_repository.dart, package:zakat_app/presentation/features/settings/settings_view_model.dart, _cloudSync, _currencyCode, _currencySymbol, _fitrPaid, _goldPrice (+20 more)

### Community 21 - "Community 21"
Cohesion: 0.08
Nodes (26): package:url_launcher/url_launcher.dart, profile_screen.dart, _card, _cmpItem, _confirmClear, createState, _ctrl, _CurrencyPickerSheet (+18 more)

### Community 22 - "Community 22"
Cohesion: 0.07
Nodes (26): _animalResult, _buildAnimalsTab, _buildCropsTab, _buildMoneyTab, _buildResultBar, _buildTradeTab, _camelsCtrl, _cowsCtrl (+18 more)

### Community 23 - "Community 23"
Cohesion: 0.08
Nodes (26): AIAssistantScreen, _AIAssistantScreenState, build, _buildExamples, _buildMessage, _buildTypingIndicator, CalendarScreen, _CalendarScreenState (+18 more)

### Community 24 - "Community 24"
Cohesion: 0.07
Nodes (26): AiMessage, AiPromptBuilder, AiResponseParser, apiKey, _arabicMsg, _baseTimeout, _baseUrl, buildSystemPrompt (+18 more)

### Community 25 - "Community 25"
Cohesion: 0.08
Nodes (25): ahadith, aiAssistantExamples, answer, benefit, camelZakatTable, color, cowZakatTable, description (+17 more)

### Community 26 - "Community 26"
Cohesion: 0.09
Nodes (25): MasrafModel, ZakatRulingModel, _answer, build, _buildQuestion, _buildResult, createState, _expanded (+17 more)

### Community 27 - "Community 27"
Cohesion: 0.08
Nodes (23): main, package:flutter/material.dart, package:zakat_app/l10n/app_localizations.dart, package:zakat_app/utils/theme.dart, build, _buildDailyReminders, _buildDaysCounter, _buildFadailCard (+15 more)

### Community 28 - "Community 28"
Cohesion: 0.08
Nodes (24): AiMessage, _addWelcome, AIScreen, _AIScreenState, build, cardColor, _controller, createState (+16 more)

### Community 29 - "Community 29"
Cohesion: 0.11
Nodes (22): FlPluginRegistry, fl_register_plugins(), FlView, GApplication, gboolean, gchar, GObject, GtkApplication (+14 more)

### Community 30 - "Community 30"
Cohesion: 0.08
Nodes (24): build, _buildEmailTab, _buildGoogleTab, _buildPhoneTab, createState, dispose, _emailCtrl, _field (+16 more)

### Community 31 - "Community 31"
Cohesion: 0.08
Nodes (23): dart:math, apiKey, _baseTimeout, _baseUrl, cause, clearHistory, code, effectiveKey (+15 more)

### Community 32 - "Community 32"
Cohesion: 0.10
Nodes (22): AiChatScreen, _AiChatScreenState, build, cardColor, _controller, createState, _ctrl, dispose (+14 more)

### Community 33 - "Community 33"
Cohesion: 0.09
Nodes (22): package:timezone/data/latest.dart, package:timezone/timezone.dart, cancel, cancelAll, _channelDesc, _channelId, _channelName, _createChannel (+14 more)

### Community 34 - "Community 34"
Cohesion: 0.16
Nodes (22): _TypingIndicator, _TypingIndicatorState, SplashScreen, _SplashScreenState, _TypingIndicator, _TypingIndicatorState, CalculatorScreen, _CalculatorScreenState (+14 more)

### Community 35 - "Community 35"
Cohesion: 0.09
Nodes (21): BuildContext, Orientation, bodySize, build, context, DeviceType, gridCols, height (+13 more)

### Community 36 - "Community 36"
Cohesion: 0.10
Nodes (20): build, _buildIssuesList, _buildQuickTable, createState, description, dispose, _expandedIndex, hanafi (+12 more)

### Community 37 - "Community 37"
Cohesion: 0.10
Nodes (20): _amount, _amountCtrl, build, _buildQuickCalc, _buildScenarioComparison, _buildYearlyProjection, _compactRow, createState (+12 more)

### Community 38 - "Community 38"
Cohesion: 0.10
Nodes (19): calculateTotal, _calculateZakat, _debtsOwed, _debtsReceive, _gold, hasReachedNisab, _money, reset (+11 more)

### Community 39 - "Community 39"
Cohesion: 0.10
Nodes (19): firebase_options.dart, build, createState, _ctrl, delayed, dispose, initializeApp, _initServicesInBackground (+11 more)

### Community 40 - "Community 40"
Cohesion: 0.12
Nodes (17): ../core/utils/app_logger.dart, ../datasources/firestore_gold_price_data_source.dart, fetchGoldPrice, _firestore, FirestoreGoldPriceDataSource, ../datasources/hive_cache_data_source.dart, HiveCacheDataSource, ../../domain/entities/gold_price_result.dart (+9 more)

### Community 41 - "Community 41"
Cohesion: 0.11
Nodes (18): FakeSettingsRepository, loadCloudSync, loadCurrency, loadDarkMode, loadFitrPaid, loadGoldPrice, loadLanguage, loadRamadanMode (+10 more)

### Community 42 - "Community 42"
Cohesion: 0.11
Nodes (17): ../data/datasources/firestore_gold_price_data_source.dart, ../data/datasources/firestore_sync_data_source.dart, ../data/datasources/hive_cache_data_source.dart, ../data/datasources/shared_prefs_storage.dart, ../data/repositories_impl/ai_chat_repository_impl.dart, ../data/repositories_impl/auth_repository_impl.dart, ../data/repositories_impl/gold_price_repository_impl.dart, ../data/repositories_impl/settings_repository_impl.dart (+9 more)

### Community 43 - "Community 43"
Cohesion: 0.11
Nodes (17): default, android, ios, macos, web, windows, lib/firebase_options.dart, appId (+9 more)

### Community 44 - "Community 44"
Cohesion: 0.12
Nodes (16): AppLogger, cache, debug, _enabled, error, firebase, goldPrice, info (+8 more)

### Community 45 - "Community 45"
Cohesion: 0.12
Nodes (15): @pragma, package:firebase_messaging/firebase_messaging.dart, package:flutter_local_notifications/flutter_local_notifications.dart, FcmService, _firebaseMessagingBackgroundHandler, hasPermission, init, _initialized (+7 more)

### Community 46 - "Community 46"
Cohesion: 0.13
Nodes (14): addWelcome, clearChat, _defaultUserMessage, hasApiKey, _isLoading, _messages, sendMessage, _sendMessageUseCase (+6 more)

### Community 47 - "Community 47"
Cohesion: 0.13
Nodes (14): ../entities/nisab_data.dart, ../entities/wealth_data.dart, ../entities/zakat_record.dart, getCountrySource, loadHistory, loadNisabDate, loadNisabHistory, loadNisabMethod (+6 more)

### Community 48 - "Community 48"
Cohesion: 0.13
Nodes (14): loadCloudSync, loadCurrency, loadDarkMode, loadFitrPaid, loadGoldPrice, loadLanguage, loadRamadanMode, saveCloudSync (+6 more)

### Community 49 - "Community 49"
Cohesion: 0.14
Nodes (13): ../../core/constants/app_constants.dart, ../entities/zakat_result.dart, static const double, calculate, calculateGoldNisab, calculateSilverNisab, calculateTotalWealth, calculateZakatDue (+5 more)

### Community 50 - "Community 50"
Cohesion: 0.14
Nodes (10): main, package:flutter_test/flutter_test.dart, package:shared_preferences/shared_preferences.dart, package:zakat_app/data/datasources/ai_prompt_builder.dart, package:zakat_app/services/nisab_service.dart, package:zakat_app/services/remote_config_service.dart, package:zakat_app/services/storage_service.dart, main (+2 more)

### Community 51 - "Community 51"
Cohesion: 0.14
Nodes (13): _auth, authStateChanges, _firestore, isSignedIn, loadData, loadHistory, saveData, saveHistory (+5 more)

### Community 52 - "Community 52"
Cohesion: 0.18
Nodes (8): Any, FlutterAppDelegate, Bool, AppDelegate, Bool, AppDelegate, NSApplication, UIApplication

### Community 53 - "Community 53"
Cohesion: 0.15
Nodes (12): Box, _box, _boxName, clear, delete, hasKey, init, keys (+4 more)

### Community 54 - "Community 54"
Cohesion: 0.17
Nodes (11): dart:convert, dart:io, ../errors/app_exception.dart, ApiClient, _defaultTimeout, getList, _maxRetries, package:http/http.dart (+3 more)

### Community 55 - "Community 55"
Cohesion: 0.17
Nodes (11): ../datasources/firestore_sync_data_source.dart, FirestoreSyncDataSource, ../../domain/entities/user_data.dart, ../../domain/repositories/auth_repository.dart, _firestore, isSignedIn, signInAnonymously, signInWithEmail (+3 more)

### Community 56 - "Community 56"
Cohesion: 0.23
Nodes (9): _In_, _In_opt_, wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), vector, string (+1 more)

### Community 57 - "Community 57"
Cohesion: 0.18
Nodes (10): ../core/errors/app_exception.dart, package:firebase_crashlytics/firebase_crashlytics.dart, CrashlyticsService, init, _initialized, log, recordAppException, recordError (+2 more)

### Community 58 - "Community 58"
Cohesion: 0.18
Nodes (9): main, package:zakat_app/domain/entities/gold_price_result.dart, package:zakat_app/domain/entities/wealth_data.dart, package:zakat_app/domain/entities/zakat_result.dart, package:zakat_app/domain/usecases/calculate_zakat.dart, package:zakat_app/presentation/features/calculator/calculator_view_model.dart, main, useCase (+1 more)

### Community 59 - "Community 59"
Cohesion: 0.18
Nodes (10): ../../../domain/repositories/settings_repository.dart, _cloudSyncEnabled, _isDarkMode, _language, loadSettings, _repo, setLanguage, toggleCloudSync (+2 more)

### Community 60 - "Community 60"
Cohesion: 0.18
Nodes (10): package:firebase_remote_config/firebase_remote_config.dart, _defaults, init, _initialized, _rc, refresh, RemoteConfigService, static bool (+2 more)

### Community 61 - "Community 61"
Cohesion: 0.18
Nodes (10): package:home_widget/home_widget.dart, static const String, _androidWidgetName, _appGroupId, getInitialWidgetUri, init, _iOSWidgetName, listenForWidgetTap (+2 more)

### Community 62 - "Community 62"
Cohesion: 0.27
Nodes (10): admin, computeNisab(), db, FALLBACK_FX, fetchFxRates(), fetchJSON(), fetchMetals(), https (+2 more)

### Community 63 - "Community 63"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 64 - "Community 64"
Cohesion: 0.20
Nodes (9): android, DefaultFirebaseOptions, ios, macos, web, windows, package:firebase_core/firebase_core.dart, package:flutter/foundation.dart (+1 more)

### Community 65 - "Community 65"
Cohesion: 0.50
Nodes (7): Bool, PBXProj, addCrashlyticsRunScriptBuildPhase(), hasCrashlyticsRunScriptBuildPhase(), isUserScriptSandboxingEnabled(), main(), setDwarfWithDsymDebugInformationFormat()

### Community 66 - "Community 66"
Cohesion: 0.25
Nodes (6): SharedPreferences, AppWidgetManager, Context, ZakatWidgetProvider, HomeWidgetProvider, IntArray

### Community 67 - "Community 67"
Cohesion: 0.29
Nodes (6): client, configuration_version, project_info, project_id, project_number, storage_bucket

### Community 68 - "Community 68"
Cohesion: 0.29
Nodes (6): code, currencies, CurrencyModel, name, symbol, List

### Community 69 - "Community 69"
Cohesion: 0.29
Nodes (6): ../entities/gold_price_result.dart, fetchGoldPrice, GoldPriceRepository, loadCachedPrice, saveCachedPrice, GoldPriceRepositoryImpl

### Community 70 - "Community 70"
Cohesion: 0.29
Nodes (4): RegisterGeneratedPlugins(), FlutterPluginRegistry, NSWindow, MainFlutterWindow

### Community 71 - "Community 71"
Cohesion: 0.29
Nodes (6): _hadithIndex, HomeViewModel, rotateHadith, _selectedIndex, setSelectedIndex, int get

### Community 72 - "Community 72"
Cohesion: 0.29
Nodes (3): RunnerTests, RunnerTests, XCTestCase

### Community 73 - "Community 73"
Cohesion: 0.33
Nodes (6): CalculatorViewModel, ChangeNotifier, ZakatProvider, ZakatProvider, ConnectivityService, SettingsViewModel

### Community 74 - "Community 74"
Cohesion: 0.33
Nodes (5): AiPromptBuilder, buildSystemPrompt, data, suggestions, welcomeMessage

### Community 75 - "Community 75"
Cohesion: 0.33
Nodes (5): handle_new_rx_page(), __lldb_init_module(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages., SBDebugger, SBFrame

### Community 76 - "Community 76"
Cohesion: 0.33
Nodes (5): dependencies, firebase-admin, name, private, version

### Community 77 - "Community 77"
Cohesion: 0.40
Nodes (4): displayName, email, uid, UserData

### Community 78 - "Community 78"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 79 - "Community 79"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 80 - "Community 80"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 81 - "Community 81"
Cohesion: 0.40
Nodes (5): computedHash, skillPath, source, sourceType, firebase-ai-logic-basics

### Community 82 - "Community 82"
Cohesion: 0.40
Nodes (5): computedHash, skillPath, source, sourceType, firebase-app-hosting-basics

### Community 83 - "Community 83"
Cohesion: 0.40
Nodes (5): computedHash, skillPath, source, sourceType, firebase-auth-basics

### Community 84 - "Community 84"
Cohesion: 0.40
Nodes (5): computedHash, skillPath, source, sourceType, firebase-basics

### Community 85 - "Community 85"
Cohesion: 0.40
Nodes (5): computedHash, skillPath, source, sourceType, firebase-crashlytics

### Community 86 - "Community 86"
Cohesion: 0.40
Nodes (5): computedHash, skillPath, source, sourceType, firebase-data-connect

### Community 87 - "Community 87"
Cohesion: 0.40
Nodes (5): computedHash, skillPath, source, sourceType, firebase-firestore

### Community 88 - "Community 88"
Cohesion: 0.40
Nodes (5): computedHash, skillPath, source, sourceType, firebase-hosting-basics

### Community 89 - "Community 89"
Cohesion: 0.40
Nodes (5): computedHash, skillPath, source, sourceType, firebase-remote-config-basics

### Community 90 - "Community 90"
Cohesion: 0.40
Nodes (5): computedHash, skillPath, source, sourceType, firebase-security-rules-auditor

### Community 91 - "Community 91"
Cohesion: 0.40
Nodes (5): xcode-project-setup, computedHash, skillPath, source, sourceType

### Community 93 - "Community 93"
Cohesion: 0.50
Nodes (3): FlutterLocalNotificationsPlugin, GeneratedPluginRegistrant, -registerWithRegistry

### Community 94 - "Community 94"
Cohesion: 0.67
Nodes (4): AppLocalizations, _AppLocalizationsDelegate, of, LocalizationsDelegate

## Knowledge Gaps
- **1650 isolated node(s):** `java.configuration.updateBuildConfiguration`, `project_number`, `project_id`, `storage_bucket`, `client` (+1645 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `_` connect `Community 0` to `Community 1`, `Community 2`, `Community 59`, `Community 27`, `Community 94`?**
  _High betweenness centrality (0.332) - this node is a cross-community bridge._
- **Why does `firebase-firestore` connect `Community 87` to `Community 40`, `Community 51`, `Community 96`?**
  _High betweenness centrality (0.049) - this node is a cross-community bridge._
- **Why does `skills` connect `Community 96` to `Community 81`, `Community 82`, `Community 83`, `Community 84`, `Community 85`, `Community 86`, `Community 87`, `Community 88`, `Community 89`, `Community 90`, `Community 91`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **What connects `java.configuration.updateBuildConfiguration`, `project_number`, `project_id` to the rest of the system?**
  _1651 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.005305039787798408 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.023529411764705882 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.0512987012987013 - nodes in this community are weakly interconnected._