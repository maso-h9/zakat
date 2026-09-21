import '../../domain/repositories/zakat_repository.dart';
import '../../domain/entities/wealth_data.dart';
import '../../domain/entities/zakat_record.dart';
import '../../domain/entities/nisab_data.dart';
import '../datasources/shared_prefs_storage.dart';

class ZakatRepositoryImpl implements ZakatRepository {
  final SharedPrefsStorage _storage;

  ZakatRepositoryImpl(this._storage);

  @override
  Future<void> saveWealth(WealthData wealth) => _storage.saveWealth(wealth);

  @override
  Future<WealthData> loadWealth() => _storage.loadWealth();

  @override
  Future<void> saveNisabDate(DateTime date) => _storage.saveNisabDate(date);

  @override
  Future<DateTime?> loadNisabDate() => _storage.loadNisabDate();

  @override
  Future<void> saveHistory(List<ZakatRecord> history) =>
      _storage.saveHistory(history);

  @override
  Future<List<ZakatRecord>> loadHistory() => _storage.loadHistory();

  @override
  Future<void> saveNisabMethod(
          NisabMethod method, double official, double custom) =>
      _storage.saveNisabMethod(method, official, custom);

  @override
  Future<Map<String, dynamic>> loadNisabMethod() =>
      _storage.loadNisabMethod();

  @override
  Future<List<NisabHistoryEntry>> loadNisabHistory() =>
      _storage.loadNisabHistory();

  @override
  Future<void> recordNisabChange(NisabHistoryEntry entry) =>
      _storage.recordNisabChange(entry);

  @override
  Future<CountrySource?> getCountrySource(String currencyCode) =>
      _storage.getCountrySource(currencyCode);
}
