// ================================================================
// nisab_service.dart — خدمة النصاب المستقلة V12
// مسؤولة عن: الحساب / Firestore / الكاش / المقارنة / السجل
// يقرأ country_sources ديناميكياً من Firestore (بند 16)
// يستخدم Country Code بدل Currency Code (بند 14)
// ================================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/app_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ── نموذج المصدر الرسمي (ديناميكي من Firestore) ──────────────
class CountrySource {
  final String countryCode; // LY, EG, SA ...
  final String name;
  final List<SourceLink> links;
  final bool supportsOfficialNisab;
  final String status; // active, deprecated, maintenance, broken
  final String lastReviewed;
  final int version;

  const CountrySource({
    required this.countryCode,
    required this.name,
    required this.links,
    required this.supportsOfficialNisab,
    required this.status,
    required this.lastReviewed,
    required this.version,
  });

  bool get isActive => status == 'active';

  factory CountrySource.fromFirestore(String id, Map<String, dynamic> data) {
    final rawLinks = data['links'] as List<dynamic>? ?? [];
    return CountrySource(
      countryCode: id,
      name: data['name'] as String? ?? '',
      supportsOfficialNisab: data['supportsOfficialNisab'] as bool? ?? false,
      status: data['status'] as String? ?? 'active',
      lastReviewed: data['lastReviewed'] as String? ?? '',
      version: data['version'] as int? ?? 1,
      links: rawLinks
          .map((l) => SourceLink.fromMap(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SourceLink {
  final String url;
  final String type; // website, facebook, telegram, pdf, youtube
  final String trustLevel; // official, government, verified, community
  final int priority;

  const SourceLink({
    required this.url,
    required this.type,
    required this.trustLevel,
    required this.priority,
  });

  factory SourceLink.fromMap(Map<String, dynamic> m) => SourceLink(
        url: m['url'] as String? ?? '',
        type: m['type'] as String? ?? 'website',
        trustLevel: m['trustLevel'] as String? ?? 'verified',
        priority: m['priority'] as int? ?? 99,
      );

  String get trustLabel {
    switch (trustLevel) {
      case 'official':
        return '🏛️ رسمي';
      case 'government':
        return '🏢 حكومي';
      case 'verified':
        return '✅ موثّق';
      default:
        return '👥 مجتمعي';
    }
  }

  String get typeIcon {
    switch (type) {
      case 'facebook':
        return '📘';
      case 'telegram':
        return '✈️';
      case 'pdf':
        return '📄';
      case 'youtube':
        return '▶️';
      default:
        return '🌐';
    }
  }
}

// ── سجل تغير النصاب ──────────────────────────────────────────
class NisabHistoryEntry {
  final DateTime date;
  final double value;
  final String method; // global, official, custom
  final String currency;

  const NisabHistoryEntry({
    required this.date,
    required this.value,
    required this.method,
    required this.currency,
  });

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'value': value,
        'method': method,
        'currency': currency,
      };

  factory NisabHistoryEntry.fromMap(Map<String, dynamic> m) =>
      NisabHistoryEntry(
        date: DateTime.parse(m['date'] as String),
        value: (m['value'] as num).toDouble(),
        method: m['method'] as String? ?? 'global',
        currency: m['currency'] as String? ?? '',
      );
}

// ════════════════════════════════════════════════════════════════
// CountrySourcesRepository — طبقة الوصول لـ Firestore (بند 18)
// ════════════════════════════════════════════════════════════════
class CountrySourcesRepository {
  static const String _collection = 'country_sources';
  static const String _boxName = 'country_sources_cache';
  static const Duration _ttl = Duration(hours: 24);

  static Box? _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  // ── خريطة العملة → Country Code ─────────────────────────────
  static const Map<String, String> _currencyToCountry = {
    'LYD': 'LY',
    'EGP': 'EG',
    'SAR': 'SA',
    'AED': 'AE',
    'KWD': 'KW',
    'QAR': 'QA',
    'JOD': 'JO',
    'MAD': 'MA',
    'TND': 'TN',
    'DZD': 'DZ',
    'USD': 'US',
    'EUR': 'EU',
    'GBP': 'GB',
  };

  static String countryCodeForCurrency(String currency) =>
      _currencyToCountry[currency] ?? currency;

  // ── جلب مصدر دولة محددة ─────────────────────────────────────
  static Future<CountrySource?> getForCountry(String countryCode) async {
    // تحقق من الكاش أولاً
    final cached = _fromCache(countryCode);
    if (cached != null) return cached;

    // جلب من Firestore
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(countryCode)
          .get()
          .timeout(const Duration(seconds: 6));

      if (doc.exists && doc.data() != null) {
        final source = CountrySource.fromFirestore(countryCode, doc.data()!);
        _saveToCache(countryCode, doc.data()!);
        return source;
      }
    } catch (e) {
      // ignore: avoid_print
      AppLogger.error('CountrySourcesRepository: فشل جلب $countryCode',
          exception: e);
    }
    return null;
  }

  // ── جلب كل المصادر (للصفحة الرسمية مستقبلاً) ───────────────
  static Future<List<CountrySource>> getAll() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(_collection)
          .where('status', isEqualTo: 'active')
          .get()
          .timeout(const Duration(seconds: 8));
      return snap.docs
          .map((d) => CountrySource.fromFirestore(d.id, d.data()))
          .where((s) => s.isActive)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static CountrySource? _fromCache(String code) {
    final ts = _box?.get('ts_$code') as String?;
    if (ts == null) return null;
    try {
      if (DateTime.now().difference(DateTime.parse(ts)) >= _ttl) {
        return null;
      }
      final raw = _box?.get('data_$code') as Map?;
      if (raw == null) return null;
      return CountrySource.fromFirestore(code, Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  static void _saveToCache(String code, Map<String, dynamic> data) {
    _box?.put('ts_$code', DateTime.now().toIso8601String());
    _box?.put('data_$code', data);
  }
}

// ════════════════════════════════════════════════════════════════
// NisabService — منطق النصاب الكامل (بند 11)
// ════════════════════════════════════════════════════════════════
class NisabService {
  static const double goldNisabGrams = 85.0;
  static const double silverNisabGrams = 595.0;

  // ── حسابات ──────────────────────────────────────────────────
  static double globalNisab(double goldPricePerGram) =>
      goldPricePerGram * goldNisabGrams;

  static double fromGramPrice(double gramPrice) => gramPrice * goldNisabGrams;

  static double fromOzAndRate(double ozPrice, double exchangeRate) =>
      (ozPrice / 31.1035) * goldNisabGrams * exchangeRate;

  // ── مقارنة النصاب (بند 7) ───────────────────────────────────
  static NisabComparison compare({
    required double globalNisabValue,
    required double activeNisabValue,
    required String activeMethod,
    required String currency,
  }) {
    final diff = activeNisabValue - globalNisabValue;
    return NisabComparison(
      globalValue: globalNisabValue,
      activeValue: activeNisabValue,
      difference: diff,
      activeMethod: activeMethod,
      currency: currency,
    );
  }

  // ── سجل النصاب (بند 8) ──────────────────────────────────────
  static const String _historyBox = 'nisab_history';
  static const String _historyKey = 'entries';

  static Future<void> recordChange({
    required double value,
    required String method,
    required String currency,
  }) async {
    final box = await Hive.openBox(_historyBox);
    final rawList = (box.get(_historyKey) as List?)
            ?.cast<Map>()
            .map((m) => NisabHistoryEntry.fromMap(Map<String, dynamic>.from(m)))
            .toList() ??
        [];

    // تجنب تسجيل نفس القيمة مرتين
    if (rawList.isNotEmpty &&
        rawList.last.value == value &&
        rawList.last.method == method &&
        rawList.last.currency == currency) {
      return;
    }

    rawList.add(NisabHistoryEntry(
      date: DateTime.now(),
      value: value,
      method: method,
      currency: currency,
    ));

    // احفظ آخر 50 إدخال فقط
    final trimmed =
        rawList.length > 50 ? rawList.sublist(rawList.length - 50) : rawList;

    await box.put(_historyKey, trimmed.map((e) => e.toMap()).toList());
  }

  static Future<List<NisabHistoryEntry>> loadHistory() async {
    final box = await Hive.openBox(_historyBox);
    final raw = (box.get(_historyKey) as List?) ?? [];
    return raw
        .cast<Map>()
        .map((m) => NisabHistoryEntry.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }
}

// ── نموذج المقارنة ────────────────────────────────────────────
class NisabComparison {
  final double globalValue;
  final double activeValue;
  final double difference;
  final String activeMethod;
  final String currency;

  const NisabComparison({
    required this.globalValue,
    required this.activeValue,
    required this.difference,
    required this.activeMethod,
    required this.currency,
  });

  bool get isHigherThanGlobal => activeValue > globalValue;
  bool get isSameAsGlobal => difference.abs() < 1;
}
