import '../entities/currency_model.dart';
import '../repositories/currency_repository.dart';

class GetAvailableCurrenciesUseCase {
  final CurrencyRepository _repo;

  GetAvailableCurrenciesUseCase(this._repo);

  Future<List<CurrencyModel>> execute() => _repo.getAvailableCurrencies();
}
