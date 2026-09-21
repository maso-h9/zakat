import '../entities/gold_price_result.dart';

abstract class GoldPriceRepository {
  Future<GoldPriceResult> fetchGoldPrice(String currencyCode);
  Future<double?> loadCachedPrice();
  Future<void> saveCachedPrice(double price);
}
