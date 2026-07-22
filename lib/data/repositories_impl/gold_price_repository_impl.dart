import '../../domain/repositories/gold_price_repository.dart';
import '../../domain/entities/gold_price_result.dart';
import '../datasources/firestore_gold_price_data_source.dart';
import '../datasources/hive_cache_data_source.dart';
import '../../core/utils/app_logger.dart';

class GoldPriceRepositoryImpl implements GoldPriceRepository {
  final FirestoreGoldPriceDataSource _firestore;
  final HiveCacheDataSource _cache;

  GoldPriceRepositoryImpl(this._firestore, this._cache);

  @override
  Future<GoldPriceResult> fetchGoldPrice(String currencyCode) async {
    // Try cache first (fast)
    final cached = _getFromCache(currencyCode);
    if (cached != null && cached.isLive) {
      return cached;
    }

    // Fetch from Firestore
    try {
      final result = await _firestore.fetchGoldPrice(currencyCode);
      if (result.pricePerGram > 0) {
        _saveToCache(currencyCode, result);
      }
      return result;
    } catch (e) {
      AppLogger.warning('GoldPriceRepository: fetch failed, using cache');
      if (cached != null) return cached;
      return GoldPriceResult.empty;
    }
  }

  @override
  Future<double?> loadCachedPrice() async {
    return _cache.read('gold_price') as double?;
  }

  @override
  Future<void> saveCachedPrice(double price) async {
    await _cache.write('gold_price', price);
  }

  GoldPriceResult? _getFromCache(String currencyCode) {
    final raw = _cache.read('gold_price_$currencyCode');
    if (raw == null) return null;
    try {
      final data = Map<String, dynamic>.from(raw as Map);
      return GoldPriceResult(
        pricePerGram: (data['pricePerGram'] as num?)?.toDouble() ?? 0,
        silverPricePerGram:
            (data['silverPricePerGram'] as num?)?.toDouble() ?? 0,
        isLive: data['isLive'] as bool? ?? false,
        formattedTime: data['formattedTime'] as String?,
        source: data['source'] as String? ?? 'cache',
      );
    } catch (e) {
      AppLogger.warning('GoldPriceRepository: cache parse failed');
      return null;
    }
  }

  void _saveToCache(String currencyCode, GoldPriceResult result) {
    _cache.write('gold_price_$currencyCode', {
      'pricePerGram': result.pricePerGram,
      'silverPricePerGram': result.silverPricePerGram,
      'isLive': result.isLive,
      'formattedTime': result.formattedTime,
      'source': result.source,
    });
  }
}
