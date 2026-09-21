import '../../domain/repositories/currency_repository.dart';
import '../../domain/entities/currency_model.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  @override
  Future<List<CurrencyModel>> getAvailableCurrencies() async {
    return currencies;
  }

  @override
  Future<CurrencyModel?> getCurrencyByCode(String code) async {
    try {
      return currencies.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }
}
