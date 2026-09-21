// ================================================================
// core/cache/cache_manager.dart — إدارة موحّدة للكاش (بند 14)
// TTL · Expiration · Refresh · Offline Support
// ================================================================
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_logger.dart';
import '../errors/app_exception.dart';

class CacheEntry<T> {
  final T data;
  final DateTime cachedAt;
  final Duration ttl;

  const CacheEntry({
    required this.data,
    required this.cachedAt,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(cachedAt) > ttl;
  bool get isValid => !isExpired;

  Duration get age => DateTime.now().difference(cachedAt);
  DateTime get expiresAt => cachedAt.add(ttl);
}

class CacheManager {
  static const String _boxName = 'app_cache';
  static Box? _box;

  static Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox(_boxName);
    AppLogger.debug('CacheManager initialized');
  }

  // ── حفظ ─────────────────────────────────────────────────────
  static Future<void> set<T>(
    String key,
    T data, {
    Duration ttl = const Duration(hours: 6),
  }) async {
    try {
      final entry = {
        'data': data is Map || data is List ? data : data.toString(),
        'cachedAt': DateTime.now().toIso8601String(),
        'ttlMs': ttl.inMilliseconds,
      };
      await _box!.put(key, entry);
      AppLogger.cache('set', key);
    } catch (e) {
      throw CacheException(detail: 'set($key)', cause: e);
    }
  }

  static Future<void> setJson(
    String key,
    Map<String, dynamic> data, {
    Duration ttl = const Duration(hours: 6),
  }) async {
    try {
      final entry = {
        'data': jsonEncode(data),
        'cachedAt': DateTime.now().toIso8601String(),
        'ttlMs': ttl.inMilliseconds,
      };
      await _box!.put(key, entry);
      AppLogger.cache('set', key);
    } catch (e) {
      throw CacheException(detail: 'setJson($key)', cause: e);
    }
  }

  // ── قراءة ────────────────────────────────────────────────────
  static CacheEntry<T>? get<T>(String key) {
    try {
      final raw = _box?.get(key) as Map?;
      if (raw == null) return null;

      final cachedAt = DateTime.parse(raw['cachedAt'] as String);
      final ttl = Duration(milliseconds: raw['ttlMs'] as int);
      final data = raw['data'] as T;

      final entry = CacheEntry<T>(data: data, cachedAt: cachedAt, ttl: ttl);
      AppLogger.cache('get', key, hit: entry.isValid);
      return entry;
    } catch (e) {
      AppLogger.warning('Cache get failed for $key: $e');
      return null;
    }
  }

  static Map<String, dynamic>? getJson(String key) {
    try {
      final raw = _box?.get(key) as Map?;
      if (raw == null) return null;

      final cachedAt = DateTime.parse(raw['cachedAt'] as String);
      final ttl = Duration(milliseconds: raw['ttlMs'] as int);

      if (DateTime.now().difference(cachedAt) > ttl) {
        AppLogger.cache('expired', key);
        return null;
      }

      final decoded = jsonDecode(raw['data'] as String) as Map<String, dynamic>;
      AppLogger.cache('get', key, hit: true);
      return decoded;
    } catch (e) {
      AppLogger.warning('Cache getJson failed for $key: $e');
      return null;
    }
  }

  // ── تحقق من صلاحية ──────────────────────────────────────────
  static bool isValid(String key) {
    try {
      final raw = _box?.get(key) as Map?;
      if (raw == null) return false;
      final cachedAt = DateTime.parse(raw['cachedAt'] as String);
      final ttl = Duration(milliseconds: raw['ttlMs'] as int);
      return DateTime.now().difference(cachedAt) <= ttl;
    } catch (_) {
      return false;
    }
  }

  // ── هل موجود؟ ───────────────────────────────────────────────
  static bool has(String key) => _box?.containsKey(key) ?? false;

  // ── حذف ──────────────────────────────────────────────────────
  static Future<void> delete(String key) async {
    await _box?.delete(key);
    AppLogger.cache('delete', key);
  }

  // ── حذف كل شيء ───────────────────────────────────────────────
  static Future<void> clear() async {
    await _box?.clear();
    AppLogger.debug('CacheManager: all cleared');
  }

  // ── حذف منتهي الصلاحية ───────────────────────────────────────
  static Future<void> evictExpired() async {
    if (_box == null) return;
    final toDelete = <String>[];
    for (final key in _box!.keys) {
      if (!isValid(key as String)) toDelete.add(key);
    }
    for (final k in toDelete) {
      await _box!.delete(k);
    }
    if (toDelete.isNotEmpty) {
      AppLogger.debug(
          'CacheManager: evicted ${toDelete.length} expired entries');
    }
  }

  // ── مساعدات ─────────────────────────────────────────────────

  /// مفاتيح مركزية — استخدمها بدل كتابة Strings في كل مكان
  static const String keyGoldPrice = 'gold_price';
  static const String keyNisabMethod = 'nisab_method';
  static const String keyOfficialNisab = 'official_nisab';
  static const String keyCustomNisab = 'custom_nisab';
  static const String keyCurrency = 'currency';
  static const String keyDarkMode = 'dark_mode';
  static const String keyLanguage = 'language';
  static const String keyCountrySource = 'country_source_'; // + countryCode
}
