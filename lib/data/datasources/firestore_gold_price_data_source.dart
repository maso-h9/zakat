import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/gold_price_result.dart';
import '../../core/utils/app_logger.dart';

class FirestoreGoldPriceDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<GoldPriceResult> fetchGoldPrice(String currencyCode) async {
    try {
      final doc = await _firestore
          .collection('gold_prices')
          .doc(currencyCode.toLowerCase())
          .get();

      if (!doc.exists) {
        AppLogger.warning('FirestoreGoldPrice: no data for $currencyCode');
        return const GoldPriceResult(
          pricePerGram: 0,
          silverPricePerGram: 0,
          isLive: false,
        );
      }

      final data = doc.data()!;
      final price = (data['price_per_gram'] as num?)?.toDouble() ?? 0;
      final silverPrice = (data['silver_price_per_gram'] as num?)?.toDouble() ?? 0;
      final lastUpdated = data['last_updated'] as Timestamp?;

      AppLogger.goldPrice(
        price,
        currencyCode,
        'firestore',
      );

      return GoldPriceResult(
        pricePerGram: price,
        silverPricePerGram: silverPrice,
        isLive: true,
        formattedTime: lastUpdated?.toDate().toString().substring(0, 16),
      );
    } catch (e) {
      AppLogger.error('FirestoreGoldPrice: fetch failed', exception: e);
      return const GoldPriceResult(
        pricePerGram: 0,
        silverPricePerGram: 0,
        isLive: false,
      );
    }
  }
}
