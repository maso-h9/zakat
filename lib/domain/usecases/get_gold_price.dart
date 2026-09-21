import '../entities/gold_price_result.dart';
import '../repositories/gold_price_repository.dart';

class GetGoldPriceUseCase {
  final GoldPriceRepository _repo;

  GetGoldPriceUseCase(this._repo);

  Future<GoldPriceResult> execute(String currencyCode) {
    return _repo.fetchGoldPrice(currencyCode);
  }
}
