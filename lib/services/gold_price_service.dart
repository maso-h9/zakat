// ================================================================
// gold_price_service.dart — V11 إصلاح مشكلة تغيير العملة
//
// المشكلة كانت: _fromHive() يتجاهل currencyCode ويرجع نفس القيمة
// الإصلاح: الكاش يخزن العملة الحالية، وعند اختلافها يجلب من Firestore
// ================================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/app_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GoldPriceService {
  static const String _col = 'prices';
  static const String _doc = 'latest';
  static const String _boxName = 'gold_cache_v2';

  // مفاتيح Hive
  static const String _kGold = 'gpg';
  static const String _kSilver = 'spg';
  static const String _kGoldN = 'gn';
  static const String _kSilN = 'sn';
  static const String _kTs = 'ts';
  static const String _kSrc = 'src';
  static const String _kCur = 'cur'; // ← جديد: العملة المخزنة

  static const Duration _ttl = Duration(hours: 6);

  static Box? _box;
  static bool _ready = false;

  // ── تهيئة Hive ────────────────────────────────────────────────
  static Future<void> initHive() async {
    if (_ready) return;
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _ready = true;
  }

  // ── هل الكاش صالح للعملة المطلوبة؟ ─────────────────────────
  // الإصلاح الجوهري: يتحقق من العملة أيضاً
  static bool _isCacheValidFor(String currency) {
    final ts = _box?.get(_kTs) as String?;
    final cur = _box?.get(_kCur) as String?;
    if (ts == null || cur == null) return false;
    if (cur != currency) return false; // ← عملة مختلفة → لا تستخدم الكاش
    try {
      return DateTime.now().difference(DateTime.parse(ts)) < _ttl;
    } catch (_) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // الدالة الرئيسية
  // ══════════════════════════════════════════════════════════════
  static Future<GoldPriceResult> fetchGoldPricePerGram(
    String currencyCode, {
    bool forceRefresh = false,
  }) async {
    // 1. كاش صالح لنفس العملة ولا طلب تحديث → أعِد فوراً
    if (!forceRefresh && _isCacheValidFor(currencyCode)) {
      return _fromHive(currencyCode);
    }

    // 2. جلب من Firestore (عملة مختلفة أو كاش منتهي أو تحديث قسري)
    try {
      final snap = await FirebaseFirestore.instance
          .collection(_col)
          .doc(_doc)
          .get()
          .timeout(const Duration(seconds: 8));

      if (snap.exists && snap.data() != null) {
        _saveToHive(snap.data()!, currencyCode);
        return _fromFirestore(snap.data()!, currencyCode);
      }
    } catch (e) {
      AppLogger.error('GoldPriceService: Firestore', exception: e);
    }

    // 3. Firestore فشل — هل عندنا كاش لأي عملة؟ استخدمه مع تحويل
    if (_box != null && ((_box!.get(_kGold) ?? 0) as num).toDouble() > 0) {
      final cachedCurrency = _box!.get(_kCur) as String? ?? 'LYD';
      if (cachedCurrency == currencyCode) {
        return _fromHive(currencyCode);
      }
      // عملة مختلفة في الكاش → استخدم fallback للعملة المطلوبة
    }

    // 4. لا شيء → قيم احتياطية للعملة المطلوبة تحديداً
    return _fallback(currencyCode);
  }

  // ── بناء النتيجة من Firestore ─────────────────────────────────
  static GoldPriceResult _fromFirestore(Map<String, dynamic> data, String cur) {
    final nisab = (data['nisab'] as Map<String, dynamic>?)?[cur];
    final gPG = (nisab?['goldPricePerGram'] as num?)?.toDouble() ??
        _estimateFromOz(data['goldUsdPerOz'], cur);
    return GoldPriceResult(
      pricePerGram: gPG,
      silverPricePerGram:
          (nisab?['silverPricePerGram'] as num?)?.toDouble() ?? 0.85,
      goldNisab: (nisab?['goldNisab'] as num?)?.toDouble() ?? gPG * 85,
      silverNisab: (nisab?['silverNisab'] as num?)?.toDouble() ?? 0.0,
      isLive: true,
      source: data['source'] as String? ?? 'firestore',
      lastUpdated: _parseDate(data['updatedAt']),
    );
  }

  // ── حفظ في Hive مع العملة ─────────────────────────────────────
  static void _saveToHive(Map<String, dynamic> data, String cur) {
    final nisab = (data['nisab'] as Map<String, dynamic>?)?[cur];
    final gPG = (nisab?['goldPricePerGram'] as num?)?.toDouble() ??
        _estimateFromOz(data['goldUsdPerOz'], cur);
    _box?.putAll({
      _kGold: gPG,
      _kSilver: (nisab?['silverPricePerGram'] as num?)?.toDouble() ?? 0.85,
      _kGoldN: (nisab?['goldNisab'] as num?)?.toDouble() ?? gPG * 85,
      _kSilN: (nisab?['silverNisab'] as num?)?.toDouble() ?? 0.0,
      _kTs: data['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      _kSrc: data['source'] as String? ?? 'firestore',
      _kCur: cur, // ← يحفظ العملة مع البيانات
    });
  }

  // ── قراءة من Hive ─────────────────────────────────────────────
  static GoldPriceResult _fromHive(String cur) {
    return GoldPriceResult(
      pricePerGram: ((_box?.get(_kGold, defaultValue: 0.0)) as num).toDouble(),
      silverPricePerGram:
          ((_box?.get(_kSilver, defaultValue: 0.0)) as num).toDouble(),
      goldNisab: ((_box?.get(_kGoldN, defaultValue: 0.0)) as num).toDouble(),
      silverNisab: ((_box?.get(_kSilN, defaultValue: 0.0)) as num).toDouble(),
      isLive: false,
      source: _box?.get(_kSrc, defaultValue: 'cache') as String? ?? 'cache',
      lastUpdated: _parseDate(_box?.get(_kTs)),
    );
  }

  // ── قيم احتياطية حسب العملة المطلوبة تحديداً ─────────────────
  static GoldPriceResult _fallback(String cur) {
    const approx = <String, double>{
      'LYD': 11400,
      'SAR': 8800,
      'AED': 8600,
      'USD': 2400,
      'EUR': 2200,
      'EGP': 74000,
      'GBP': 1900,
      'KWD': 735,
      'QAR': 8740,
      'JOD': 1700,
      'MAD': 24000,
      'TND': 7500,
    };
    final g = approx[cur] ?? 2400.0;
    final s = g * 0.000355;
    return GoldPriceResult(
      pricePerGram: g,
      silverPricePerGram: s,
      goldNisab: g * 85,
      silverNisab: s * 595,
      isLive: false,
      source: 'offline_fallback',
      lastUpdated: null,
    );
  }

  // ── مساعدات ───────────────────────────────────────────────────
  static double _estimateFromOz(dynamic oz, String cur) {
    const fx = <String, double>{
      'LYD': 4.85,
      'SAR': 3.75,
      'AED': 3.67,
      'EGP': 30.9,
      'USD': 1.0,
      'EUR': 0.92,
      'GBP': 0.79,
      'KWD': 0.31,
      'QAR': 3.64,
      'JOD': 0.71,
      'MAD': 10.1,
      'TND': 3.12,
    };
    return ((oz as num?)?.toDouble() ?? 2350.0) / 31.1035 * (fx[cur] ?? 1.0);
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v as String);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearCache() async => _box?.clear();

  static double convert(double amount, String from, String to) {
    const fx = <String, double>{
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
    return amount / (fx[from] ?? 1.0) * (fx[to] ?? 1.0);
  }
}

// ── GoldPriceResult ───────────────────────────────────────────
class GoldPriceResult {
  final double pricePerGram;
  final double silverPricePerGram;
  final double goldNisab;
  final double silverNisab;
  final bool isLive;
  final String source;
  final DateTime? lastUpdated;

  const GoldPriceResult({
    required this.pricePerGram,
    required this.silverPricePerGram,
    required this.goldNisab,
    required this.silverNisab,
    required this.isLive,
    required this.source,
    required this.lastUpdated,
  });

  String get statusText {
    if (source == 'offline_fallback') return '⚠️ Estimated price';
    return isLive ? '✅ Live price' : '🕐 Local cache';
  }

  String get formattedTime {
    if (lastUpdated == null) return '';
    final t = lastUpdated!.toLocal();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}
