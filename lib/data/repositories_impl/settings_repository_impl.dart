import '../../domain/repositories/settings_repository.dart';
import '../datasources/shared_prefs_storage.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPrefsStorage _prefs;

  SettingsRepositoryImpl(this._prefs);

  @override
  Future<void> saveCurrency(String code, String symbol) =>
      _prefs.saveCurrency(code, symbol);

  @override
  Future<Map<String, String>> loadCurrency() => _prefs.loadCurrency();

  @override
  Future<void> saveDarkMode(bool isDark) => _prefs.saveDarkMode(isDark);

  @override
  Future<bool> loadDarkMode() => _prefs.loadDarkMode();

  @override
  Future<void> saveLanguage(String langCode) =>
      _prefs.saveLanguage(langCode);

  @override
  Future<String> loadLanguage() => _prefs.loadLanguage();

  @override
  Future<void> saveRamadanMode(bool on) => _prefs.saveRamadanMode(on);

  @override
  Future<bool> loadRamadanMode() => _prefs.loadRamadanMode();

  @override
  Future<void> saveFitrPaid(bool paid) => _prefs.saveFitrPaid(paid);

  @override
  Future<bool> loadFitrPaid() => _prefs.loadFitrPaid();

  @override
  Future<void> saveCloudSync(bool enabled) =>
      _prefs.saveCloudSync(enabled);

  @override
  Future<bool> loadCloudSync() => _prefs.loadCloudSync();

  @override
  Future<void> saveGoldPrice(double price) =>
      _prefs.saveGoldPrice(price);

  @override
  Future<double?> loadGoldPrice() => _prefs.loadGoldPrice();
}
