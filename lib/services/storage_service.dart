import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/zakat_provider.dart';

class StorageService {
  static const _keyWealth = 'wealth_data';
  static const _keyNisabDate = 'nisab_date';
  static const _keyHistory = 'zakat_history';
  static const _keyCurrency = 'currency';
  static const _keyCurrencySymbol = 'currency_symbol';
  static const _keyGoldPrice = 'gold_price';
  static const _keyRamadanMode = 'ramadan_mode';
  static const _keyFitrPaid = 'fitr_paid';
  static const _keyDarkMode = 'dark_mode';
  static const _keyCloudSync = 'cloud_sync';
  static const _keyLanguage = 'language'; // جديد

  static Future<void> saveWealth(ZakatProvider p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keyWealth,
        jsonEncode({
          'money': p.savedMoney,
          'gold': p.goldGrams,
          'silver': p.silverGrams,
          'trade': p.tradeGoods,
          'debtsOwed': p.debtsOwed,
          'debtsReceive': p.debtsToReceive,
        }));
  }

  static Future<void> loadWealth(ZakatProvider p) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyWealth);
    if (raw == null) return;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    p.updateWealth(
      money: (data['money'] as num?)?.toDouble() ?? 0,
      gold: (data['gold'] as num?)?.toDouble() ?? 0,
      silver: (data['silver'] as num?)?.toDouble() ?? 0,
      trade: (data['trade'] as num?)?.toDouble() ?? 0,
      debtsOwedVal: (data['debtsOwed'] as num?)?.toDouble() ?? 0,
      debtsReceive: (data['debtsReceive'] as num?)?.toDouble() ?? 0,
    );
  }

  static Future<void> saveNisabDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNisabDate, date.toIso8601String());
  }

  static Future<DateTime?> loadNisabDate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyNisabDate);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  static Future<void> saveHistory(List<ZakatRecord> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _keyHistory,
        history
            .map((r) => jsonEncode({
                  'year': r.year,
                  'amount': r.amount,
                  'wealth': r.wealth,
                  'date': r.date.toIso8601String(),
                  'note': r.note,
                }))
            .toList());
  }

  static Future<List<ZakatRecord>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_keyHistory) ?? []).map((s) {
      final d = jsonDecode(s) as Map<String, dynamic>;
      return ZakatRecord(
        year: d['year'] as int,
        amount: (d['amount'] as num).toDouble(),
        wealth: (d['wealth'] as num).toDouble(),
        date: DateTime.parse(d['date'] as String),
        note: d['note'] as String? ?? '',
      );
    }).toList();
  }

  static Future<void> saveCurrency(String code, String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, code);
    await prefs.setString(_keyCurrencySymbol, symbol);
  }

  static Future<Map<String, String>> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'code': prefs.getString(_keyCurrency) ?? 'LYD',
      'symbol': prefs.getString(_keyCurrencySymbol) ?? 'د.ل',
    };
  }

  static Future<void> saveGoldPrice(double price) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyGoldPrice, price);
  }

  static Future<double?> loadGoldPrice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyGoldPrice);
  }

  static Future<void> saveRamadanMode(bool on) async =>
      (await SharedPreferences.getInstance()).setBool(_keyRamadanMode, on);
  static Future<bool> loadRamadanMode() async =>
      (await SharedPreferences.getInstance()).getBool(_keyRamadanMode) ?? false;

  static Future<void> saveFitrPaid(bool paid) async =>
      (await SharedPreferences.getInstance()).setBool(_keyFitrPaid, paid);
  static Future<bool> loadFitrPaid() async =>
      (await SharedPreferences.getInstance()).getBool(_keyFitrPaid) ?? false;

  static Future<void> saveDarkMode(bool on) async =>
      (await SharedPreferences.getInstance()).setBool(_keyDarkMode, on);
  static Future<bool> loadDarkMode() async =>
      (await SharedPreferences.getInstance()).getBool(_keyDarkMode) ?? false;

  static Future<void> saveCloudSync(bool on) async =>
      (await SharedPreferences.getInstance()).setBool(_keyCloudSync, on);
  static Future<bool> loadCloudSync() async =>
      (await SharedPreferences.getInstance()).getBool(_keyCloudSync) ?? false;

  static Future<void> saveLanguage(String code) async =>
      (await SharedPreferences.getInstance()).setString(_keyLanguage, code);
  static Future<String> loadLanguage() async =>
      (await SharedPreferences.getInstance()).getString(_keyLanguage) ?? 'ar';

  static Future<void> clearAll() async =>
      (await SharedPreferences.getInstance()).clear();
}
