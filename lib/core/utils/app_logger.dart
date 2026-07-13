// ================================================================
// core/utils/app_logger.dart — Logger مركزي (بند 6)
// يُعطَّل تلقائياً في Release Mode
// ================================================================
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  AppLogger._();

  static bool _enabled = kDebugMode;

  static void setEnabled(bool value) => _enabled = value;

  // ── API Requests ────────────────────────────────────────────
  static void request(String url, {Map<String, dynamic>? params}) {
    if (!_enabled) return;
    _log(LogLevel.debug,
        '🌐 REQUEST: $url${params != null ? '\n   params: $params' : ''}');
  }

  static void response(String url, int statusCode, {String? body}) {
    if (!_enabled) return;
    final icon = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    _log(LogLevel.info,
        '$icon RESPONSE [$statusCode]: $url${body != null ? '\n   ${body.substring(0, body.length.clamp(0, 200))}' : ''}');
  }

  // ── Firebase ────────────────────────────────────────────────
  static void firebase(String operation, {String? collection, String? doc}) {
    if (!_enabled) return;
    _log(LogLevel.debug,
        '🔥 FIREBASE: $operation${collection != null ? ' [$collection${doc != null ? '/$doc' : ''}]' : ''}');
  }

  // ── Cache ───────────────────────────────────────────────────
  static void cache(String action, String key, {bool hit = false}) {
    if (!_enabled) return;
    final icon = hit ? '⚡' : '💾';
    _log(LogLevel.debug,
        '$icon CACHE ${hit ? "HIT" : action.toUpperCase()}: $key');
  }

  // ── General ─────────────────────────────────────────────────
  static void debug(String msg) {
    if (_enabled) _log(LogLevel.debug, '🔍 $msg');
  }

  static void info(String msg) {
    if (_enabled) _log(LogLevel.info, 'ℹ️  $msg');
  }

  static void warning(String msg) {
    if (_enabled) _log(LogLevel.warning, '⚠️  $msg');
  }

  // ── Errors ──────────────────────────────────────────────────
  static void error(String msg, {Object? exception, StackTrace? stack}) {
    if (!_enabled) return;
    _log(LogLevel.error, '❌ ERROR: $msg');
    if (exception != null) _log(LogLevel.error, '   Exception: $exception');
    if (stack != null && kDebugMode) {
      _log(LogLevel.error,
          '   Stack: ${stack.toString().split('\n').take(5).join('\n   ')}');
    }
  }

  // ── Zakat specific ──────────────────────────────────────────
  static void goldPrice(double price, String currency, String source) {
    if (!_enabled) return;
    _log(LogLevel.info, '🥇 GOLD: $price $currency/gram [source: $source]');
  }

  static void nisab(double value, String currency, String method) {
    if (!_enabled) return;
    _log(LogLevel.info, '📊 NISAB: $value $currency [method: $method]');
  }

  static void zakat(double wealth, double zakat, String currency) {
    if (!_enabled) return;
    _log(LogLevel.info, '🕌 ZAKAT: wealth=$wealth, due=$zakat $currency');
  }

  // ── internal ────────────────────────────────────────────────
  static void _log(LogLevel level, String msg) {
    final time = DateTime.now().toString().substring(11, 19);
    // ignore: avoid_print
    print('[$time] $msg');
  }
}
