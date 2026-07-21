class AppConstants {
  AppConstants._();

  static const String appName = 'Zakat App';
  static const String appNameAr = 'تطبيق الزكاة';
  static const String version = '1.4.0+5';

  // Zakat
  static const double zakatRate = 0.025;
  static const double goldNisabGrams = 85;
  static const double silverNisabGrams = 595;
  static const int hijriYearDays = 354;

  // API
  static const Duration apiTimeout = Duration(seconds: 60);
  static const int maxRetries = 2;
  static const int maxChatHistory = 20;

  // Gemini model
  static const String geminiModel = 'gemini-2.0-flash';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';

  // Storage keys
  static const String keyCurrencyCode = 'currency_code';
  static const String keyCurrencySymbol = 'currency_symbol';
  static const String keyDarkMode = 'dark_mode';
  static const String keyLanguage = 'language';
  static const String keyRamadan = 'ramadan_mode';
  static const String keyFitrPaid = 'fitr_paid';
  static const String keyCloudSync = 'cloud_sync';
  static const String keyGoldPrice = 'saved_gold_price';
  static const String keyMoney = 'saved_money';
  static const String keyGold = 'saved_gold';
  static const String keySilver = 'saved_silver';
  static const String keyTrade = 'saved_trade';
  static const String keyDebtsOwed = 'saved_debts_owed';
  static const String keyDebtsReceive = 'saved_debts_receive';
  static const String keyNisabDate = 'nisab_date';
  static const String keyNisabMethod = 'nisab_method';
  static const String keyNisabOfficial = 'nisab_official';
  static const String keyNisabCustom = 'nisab_custom';
}
