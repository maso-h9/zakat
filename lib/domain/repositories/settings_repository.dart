abstract class SettingsRepository {
  Future<void> saveCurrency(String code, String symbol);
  Future<Map<String, String>> loadCurrency();

  Future<void> saveDarkMode(bool isDark);
  Future<bool> loadDarkMode();

  Future<void> saveLanguage(String langCode);
  Future<String> loadLanguage();

  Future<void> saveRamadanMode(bool on);
  Future<bool> loadRamadanMode();

  Future<void> saveFitrPaid(bool paid);
  Future<bool> loadFitrPaid();

  Future<void> saveCloudSync(bool enabled);
  Future<bool> loadCloudSync();

  Future<void> saveGoldPrice(double price);
  Future<double?> loadGoldPrice();
}
