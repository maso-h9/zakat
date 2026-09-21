import '../entities/wealth_data.dart';
import '../entities/zakat_record.dart';
import '../entities/nisab_data.dart';

abstract class ZakatRepository {
  Future<void> saveWealth(WealthData wealth);
  Future<WealthData> loadWealth();

  Future<void> saveNisabDate(DateTime date);
  Future<DateTime?> loadNisabDate();

  Future<void> saveHistory(List<ZakatRecord> history);
  Future<List<ZakatRecord>> loadHistory();

  Future<void> saveNisabMethod(
      NisabMethod method, double official, double custom);
  Future<Map<String, dynamic>> loadNisabMethod();

  Future<List<NisabHistoryEntry>> loadNisabHistory();
  Future<void> recordNisabChange(NisabHistoryEntry entry);

  Future<CountrySource?> getCountrySource(String currencyCode);
}
