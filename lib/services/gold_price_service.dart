// ================================================================
// gold_price_service.dart — يقرأ من Firestore (تملأها GitHub Actions)
// Offline First: Hive كاش محلي — يعمل بدون إنترنت
// لا يتصل بأي Gold API مباشرة من التطبيق
// ================================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GoldPriceService {
  // ──────────────────────────────────────────────
  // مسار Firestore (نفس المسار الذي تكتب فيه GitHub Actions)
  // ──────────────────────────────────────────────
  static const String _collection = 'prices';
  static const String _document = 'latest';

  // ──────────────────────────────────────────────
  // مفاتيح Hive للكاش المحلي
  // ──────────────────────────────────────────────
  static const String _boxName = 'gold_price_cache';
  static const String _keyGoldPerGram = 'gold_per_gram';
  static const String _keySilverPerGram = 'silver_per_gram';
  static const String _keyGoldNisab = 'gold_nisab';
  static const String _keySilverNisab = 'silver_nisab';
  static const String _keyUpdatedAt = 'updated_at';
  static const String _keySource = 'source';

  // ──────────────────────────────────────────────
  // الكاش صالح 6 ساعات (نفس جدول GitHub Actions)
  // ──────────────────────────────────────────────
  static const Duration _cacheDuration = Duration(hours: 6);

  late Box _box;
  bool _initialized = false;

  // ──────────────────────────────────────────────
  // تهيئة Hive (استدعِ مرة واحدة في main.dart)
  // ──────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _initialized = true;
  }

  // ──────────────────────────────────────────────
  // هل الكاش لا يزال صالحاً؟
  // ──────────────────────────────────────────────
  bool get _isCacheValid {
    final String? updatedAt = _box.get(_keyUpdatedAt);
    if (updatedAt == null) return false;
    try {
      final cached = DateTime.parse(updatedAt);
      return DateTime.now().difference(cached) < _cacheDuration;
    } catch (_) {
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // الدالة الرئيسية: أعِد بيانات السعر والنصاب
  // ──────────────────────────────────────────────
  Future<PriceData> fetchPrices(String currency) async {
    // 1. إذا الكاش صالح → أعِد منه مباشرة (لا اتصال بالإنترنت)
    if (_isCacheValid) {
      return _fromCache(currency);
    }

    // 2. حاول جلب بيانات جديدة من Firestore
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(_document)
          .get()
          .timeout(const Duration(seconds: 8));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        await _saveToCache(data, currency);
        return _fromFirestoreData(data, currency);
      }
    } catch (e) {
      // فشل الاتصال بـ Firestore — استخدم الكاش القديم
      debugLog('Firestore fetch failed: $e — using cached data');
    }

    // 3. كل شيء فشل → أعِد آخر كاش محفوظ (حتى لو قديم)
    if (_box.containsKey(_keyGoldPerGram)) {
      return _fromCache(currency);
    }

    // 4. لا يوجد أي بيانات على الإطلاق → قيم احتياطية ثابتة
    return _fallbackData(currency);
  }

  // ──────────────────────────────────────────────
  // بناء PriceData من Firestore document
  // ──────────────────────────────────────────────
  PriceData _fromFirestoreData(Map<String, dynamic> data, String currency) {
    final nisab = (data['nisab'] as Map<String, dynamic>?)?[currency];
    return PriceData(
      goldPricePerGram: (nisab?['goldPricePerGram'] as num?)?.toDouble() ??
          _estimateGoldPerGram(data),
      silverPricePerGram:
          (nisab?['silverPricePerGram'] as num?)?.toDouble() ?? 0.85,
      goldNisab: (nisab?['goldNisab'] as num?)?.toDouble() ?? 0.0,
      silverNisab: (nisab?['silverNisab'] as num?)?.toDouble() ?? 0.0,
      updatedAt:
          data['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      source: data['source'] as String? ?? 'firestore',
      isLive: true,
    );
  }

  // ──────────────────────────────────────────────
  // تخزين في Hive
  // ──────────────────────────────────────────────
  Future<void> _saveToCache(Map<String, dynamic> data, String currency) async {
    final nisab = (data['nisab'] as Map<String, dynamic>?)?[currency];
    await _box.putAll({
      _keyGoldPerGram: (nisab?['goldPricePerGram'] as num?)?.toDouble() ??
          _estimateGoldPerGram(data),
      _keySilverPerGram:
          (nisab?['silverPricePerGram'] as num?)?.toDouble() ?? 0.85,
      _keyGoldNisab: (nisab?['goldNisab'] as num?)?.toDouble() ?? 0.0,
      _keySilverNisab: (nisab?['silverNisab'] as num?)?.toDouble() ?? 0.0,
      _keyUpdatedAt:
          data['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      _keySource: data['source'] as String? ?? 'firestore',
    });
  }

  // ──────────────────────────────────────────────
  // قراءة من Hive
  // ──────────────────────────────────────────────
  PriceData _fromCache(String currency) {
    return PriceData(
      goldPricePerGram:
          (_box.get(_keyGoldPerGram, defaultValue: 0.0) as num).toDouble(),
      silverPricePerGram:
          (_box.get(_keySilverPerGram, defaultValue: 0.0) as num).toDouble(),
      goldNisab: (_box.get(_keyGoldNisab, defaultValue: 0.0) as num).toDouble(),
      silverNisab:
          (_box.get(_keySilverNisab, defaultValue: 0.0) as num).toDouble(),
      updatedAt: _box.get(_keyUpdatedAt, defaultValue: '') as String,
      source: _box.get(_keySource, defaultValue: 'cache') as String,
      isLive: false,
    );
  }

  // ──────────────────────────────────────────────
  // قيم احتياطية (أول تشغيل بدون إنترنت نهائياً)
  // ──────────────────────────────────────────────
  PriceData _fallbackData(String currency) {
    // تقدير تقريبي ثابت لكل عملة عند غياب كامل للاتصال
    const Map<String, double> approxGoldPerGram = {
      'LYD': 11400.0,
      'SAR': 8800.0,
      'AED': 8600.0,
      'USD': 2400.0,
      'EUR': 2200.0,
      'EGP': 74000.0,
      'GBP': 1900.0,
      'KWD': 735.0,
    };
    final gold = approxGoldPerGram[currency] ?? 2400.0;
    final silver = gold * 0.000354; // نسبة تقريبية ذهب/فضة
    return PriceData(
      goldPricePerGram: gold,
      silverPricePerGram: silver,
      goldNisab: gold * 85,
      silverNisab: silver * 595,
      updatedAt: '',
      source: 'offline_fallback',
      isLive: false,
    );
  }

  // ──────────────────────────────────────────────
  // مساعد: احسب سعر الجرام من أوقية USD (للبيانات القديمة)
  // ──────────────────────────────────────────────
  double _estimateGoldPerGram(Map<String, dynamic> data) {
    final oz = (data['goldUsdPerOz'] as num?)?.toDouble() ?? 2350.0;
    return oz / 31.1035;
  }

  // ──────────────────────────────────────────────
  // مسح الكاش يدوياً (من شاشة الإعدادات)
  // ──────────────────────────────────────────────
  Future<void> clearCache() async {
    await _box.clear();
  }

  void debugLog(String msg) {
    // ignore: avoid_print
    print('[GoldPriceService] $msg');
  }
}

// ──────────────────────────────────────────────
// نموذج البيانات
// ──────────────────────────────────────────────
class PriceData {
  final double goldPricePerGram;
  final double silverPricePerGram;
  final double goldNisab;
  final double silverNisab;
  final String updatedAt;
  final String source;
  final bool isLive;

  const PriceData({
    required this.goldPricePerGram,
    required this.silverPricePerGram,
    required this.goldNisab,
    required this.silverNisab,
    required this.updatedAt,
    required this.source,
    required this.isLive,
  });

  /// نص يُعرض للمستخدم: "سعر مباشر" أو "آخر تحديث: ..."
  String statusText(bool isArabic) {
    if (source == 'offline_fallback') {
      return isArabic
          ? '⚠️ سعر تقديري — لا يوجد اتصال'
          : '⚠️ Estimated — no connection';
    }
    if (!isLive && updatedAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(updatedAt).toLocal();
        final formatted =
            '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
        return isArabic
            ? '🕐 آخر تحديث: $formatted'
            : '🕐 Last updated: $formatted';
      } catch (_) {}
    }
    return isArabic ? '✅ سعر مباشر' : '✅ Live price';
  }
}
