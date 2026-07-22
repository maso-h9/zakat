import '../entities/currency_model.dart';

abstract class CurrencyRepository {
  Future<List<CurrencyModel>> getAvailableCurrencies();
  Future<CurrencyModel?> getCurrencyByCode(String code);
}
