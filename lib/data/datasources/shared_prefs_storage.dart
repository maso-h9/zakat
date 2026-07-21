import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/zakat_repository.dart';
import '../../domain/entities/wealth_data.dart';
import '../../domain/entities/zakat_record.dart';
import '../../domain/entities/nisab_data.dart';
import '../../core/utils/app_logger.dart';

class SharedPrefsStorage implements SettingsRepository, ZakatRepository {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ════════════════════════════════════════════════════════════
  // Batch load — single SharedPreferences access for fast startup
  // ════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> loadAll() async {
    final p = await _instance;
    return {
      'wealth': p.getString('wealth_data'),
      'nisabDate': p.getString('nisab_date'),
      'history': p.getStringList('zakat_history'),
      'currencyCode': p.getString('currency_code') ?? 'LYD',
      'currencySymbol': p.getString('currency_symbol') ?? 'د.ل',
      'ramadanMode': p.getBool('ramadan_mode') ?? false,
      'fitrPaid': p.getBool('fitr_paid') ?? false,
      'darkMode': p.getBool('dark_mode') ?? false,
      'cloudSync': p.getBool('cloud_sync') ?? false,
      'language': p.getString('language') ?? 'ar',
      'nisabMethod': p.getInt('nisab_method') ?? 0,
      'nisabOfficial': p.getDouble('nisab_official') ?? 0.0,
      'nisabCustom': p.getDouble('nisab_custom') ?? 0.0,
      'goldPrice': p.getDouble('saved_gold_price'),
    };
  }

  // ════════════════════════════════════════════════════════════
  // SettingsRepository
  // ════════════════════════════════════════════════════════════
  @override
  Future<void> saveCurrency(String code, String symbol) async {
    final p = await _instance;
    await p.setString('currency_code', code);
    await p.setString('currency_symbol', symbol);
  }

  @override
  Future<Map<String, String>> loadCurrency() async {
    final p = await _instance;
    return {
      'code': p.getString('currency_code') ?? 'LYD',
      'symbol': p.getString('currency_symbol') ?? 'د.ل',
    };
  }

  @override
  Future<void> saveDarkMode(bool isDark) async =>
      (await _instance).setBool('dark_mode', isDark);

  @override
  Future<bool> loadDarkMode() async =>
      (await _instance).getBool('dark_mode') ?? false;

  @override
  Future<void> saveLanguage(String langCode) async =>
      (await _instance).setString('language', langCode);

  @override
  Future<String> loadLanguage() async =>
      (await _instance).getString('language') ?? 'ar';

  @override
  Future<void> saveRamadanMode(bool on) async =>
      (await _instance).setBool('ramadan_mode', on);

  @override
  Future<bool> loadRamadanMode() async =>
      (await _instance).getBool('ramadan_mode') ?? false;

  @override
  Future<void> saveFitrPaid(bool paid) async =>
      (await _instance).setBool('fitr_paid', paid);

  @override
  Future<bool> loadFitrPaid() async =>
      (await _instance).getBool('fitr_paid') ?? false;

  @override
  Future<void> saveCloudSync(bool enabled) async =>
      (await _instance).setBool('cloud_sync', enabled);

  @override
  Future<bool> loadCloudSync() async =>
      (await _instance).getBool('cloud_sync') ?? false;

  @override
  Future<void> saveGoldPrice(double price) async =>
      (await _instance).setDouble('saved_gold_price', price);

  @override
  Future<double?> loadGoldPrice() async =>
      (await _instance).getDouble('saved_gold_price');

  // ════════════════════════════════════════════════════════════
  // ZakatRepository
  // ════════════════════════════════════════════════════════════
  @override
  Future<void> saveWealth(WealthData wealth) async {
    final p = await _instance;
    await p.setString('wealth_data', jsonEncode(wealth.toMap()));
  }

  @override
  Future<WealthData> loadWealth() async {
    final p = await _instance;
    final raw = p.getString('wealth_data');
    if (raw == null) return WealthData.empty;
    try {
      return WealthData.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      AppLogger.warning('loadWealth failed: $e');
      return WealthData.empty;
    }
  }

  @override
  Future<void> saveNisabDate(DateTime date) async =>
      (await _instance).setString('nisab_date', date.toIso8601String());

  @override
  Future<DateTime?> loadNisabDate() async {
    final raw = (await _instance).getString('nisab_date');
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  @override
  Future<void> saveHistory(List<ZakatRecord> history) async {
    final p = await _instance;
    await p.setStringList(
      'zakat_history',
      history.map((r) => jsonEncode(r.toMap())).toList(),
    );
  }

  @override
  Future<List<ZakatRecord>> loadHistory() async {
    final p = await _instance;
    final raw = p.getStringList('zakat_history') ?? [];
    return raw.map((s) {
      final d = jsonDecode(s) as Map<String, dynamic>;
      return ZakatRecord.fromMap(d);
    }).toList();
  }

  @override
  Future<void> saveNisabMethod(
      NisabMethod method, double official, double custom) async {
    final p = await _instance;
    await p.setInt('nisab_method', method.index);
    await p.setDouble('nisab_official', official);
    await p.setDouble('nisab_custom', custom);
  }

  @override
  Future<Map<String, dynamic>> loadNisabMethod() async {
    final p = await _instance;
    final idx = p.getInt('nisab_method') ?? 0;
    return {
      'method': NisabMethod.values[idx.clamp(0, 2)],
      'official': p.getDouble('nisab_official') ?? 0.0,
      'custom': p.getDouble('nisab_custom') ?? 0.0,
    };
  }

  @override
  Future<List<NisabHistoryEntry>> loadNisabHistory() async {
    final p = await _instance;
    final raw = p.getStringList('nisab_history') ?? [];
    return raw.map((s) {
      final d = jsonDecode(s) as Map<String, dynamic>;
      return NisabHistoryEntry.fromMap(d);
    }).toList();
  }

  @override
  Future<void> recordNisabChange(NisabHistoryEntry entry) async {
    final p = await _instance;
    final raw = p.getStringList('nisab_history') ?? [];
    raw.add(jsonEncode(entry.toMap()));
    await p.setStringList('nisab_history', raw);
  }

  @override
  Future<CountrySource?> getCountrySource(String currencyCode) async {
    final p = await _instance;
    final raw = p.getString('country_source_$currencyCode');
    if (raw == null) return null;
    try {
      final d = jsonDecode(raw) as Map<String, dynamic>;
      return CountrySource(
        countryCode: d['code'] ?? '',
        sourceName: d['name'] ?? '',
        sourceUrl: d['url'] ?? '',
        description: d['desc'] ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}
