// ================================================================
// gold_price_service.dart — سعر الذهب (تحديث كل 30 دقيقة)
// lib/services/gold_price_service.dart
// ================================================================
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class GoldPriceService {
  static const _metalUrl = 'https://metals.live/api/v1/spot/gold';
  static const _fxUrl = 'https://open.er-api.com/v6/latest/USD';

  // Cache 30 دقيقة فقط (كان 6 ساعات — سبب ثبات السعر)
  static const _cacheMinutes = 30;

  static final Map<String, double> _fxRates = {
    'USD': 1.0,
    'LYD': 4.85,
    'SAR': 3.75,
    'AED': 3.67,
    'EGP': 30.9,
    'EUR': 0.92,
    'GBP': 0.79,
    'KWD': 0.31,
    'QAR': 3.64,
    'JOD': 0.71,
    'MAD': 10.1,
    'TND': 3.12,
  };

  static double _goldUsdPerOz = 2350.0;
  static DateTime? _lastFetch;

  static bool get _isStale =>
      _lastFetch == null ||
      DateTime.now().difference(_lastFetch!).inMinutes >= _cacheMinutes;

  static Future<GoldPriceResult> fetchGoldPricePerGram(String currencyCode,
      {bool forceRefresh = false}) async {
    if (!_isStale && !forceRefresh) {
      return _buildResult(currencyCode, isLive: true);
    }
    try {
      // جلب سعر الذهب
      final goldResp = await http.get(Uri.parse(_metalUrl), headers: {
        'Cache-Control': 'no-cache'
      }).timeout(const Duration(seconds: 10));

      if (goldResp.statusCode == 200) {
        final data = jsonDecode(goldResp.body);
        if (data is List && data.isNotEmpty && data[0]['gold'] != null) {
          _goldUsdPerOz = (data[0]['gold'] as num).toDouble();
        } else if (data is Map && data['gold'] != null) {
          _goldUsdPerOz = (data['gold'] as num).toDouble();
        }
      }

      // جلب أسعار الصرف
      final fxResp = await http.get(Uri.parse(_fxUrl), headers: {
        'Cache-Control': 'no-cache'
      }).timeout(const Duration(seconds: 10));

      if (fxResp.statusCode == 200) {
        final fxData = jsonDecode(fxResp.body) as Map<String, dynamic>;
        if (fxData['rates'] != null) {
          final rates = fxData['rates'] as Map<String, dynamic>;
          for (final entry in rates.entries) {
            _fxRates[entry.key] = (entry.value as num).toDouble();
          }
        }
      }

      _lastFetch = DateTime.now();
      await StorageService.saveGoldPrice(_goldPricePerGram(currencyCode));
      return _buildResult(currencyCode, isLive: true);
    } catch (_) {
      final saved = await StorageService.loadGoldPrice();
      return GoldPriceResult(
        pricePerGram: saved ?? _goldPricePerGram(currencyCode),
        isLive: false,
        lastUpdated: _lastFetch,
      );
    }
  }

  static double _goldPricePerGram(String currency) {
    final usdPerGram = _goldUsdPerOz / 31.1035;
    final rate = _fxRates[currency] ?? 1.0;
    return usdPerGram * rate;
  }

  static GoldPriceResult _buildResult(String currency, {bool isLive = false}) {
    return GoldPriceResult(
      pricePerGram: _goldPricePerGram(currency),
      isLive: isLive,
      lastUpdated: _lastFetch,
    );
  }

  static double convert(double amount, String from, String to) {
    final fromRate = _fxRates[from] ?? 1.0;
    final toRate = _fxRates[to] ?? 1.0;
    return amount / fromRate * toRate;
  }
}

class GoldPriceResult {
  final double pricePerGram;
  final bool isLive;
  final DateTime? lastUpdated;

  const GoldPriceResult({
    required this.pricePerGram,
    required this.isLive,
    this.lastUpdated,
  });

  String get statusText => isLive ? 'سعر مباشر' : 'سعر تقديري';

  String get formattedTime {
    if (lastUpdated == null) return '';
    final h = lastUpdated!.hour.toString().padLeft(2, '0');
    final m = lastUpdated!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
