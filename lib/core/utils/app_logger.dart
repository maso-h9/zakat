import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  AppLogger._();

  static bool _enabled = kDebugMode;
  static LogLevel _minLevel = LogLevel.debug;
  static final List<String> _sessionLogs = [];
  static const int _maxSessionLogs = 200;

  static void setEnabled(bool value) => _enabled = value;
  static void setMinLevel(LogLevel level) => _minLevel = level;

  // ── Session Logs ────────────────────────────────────────────
  static List<String> get sessionLogs => List.unmodifiable(_sessionLogs);

  static void clearSessionLogs() => _sessionLogs.clear();

  // ── API Requests ────────────────────────────────────────────
  static void request(String url, {Map<String, dynamic>? params}) {
    if (!_enabled) return;
    _log(LogLevel.debug,
        'REQUEST: $url${params != null ? '\n   params: $params' : ''}');
  }

  static void response(String url, int statusCode, {String? body}) {
    if (!_enabled) return;
    final icon = statusCode >= 200 && statusCode < 300 ? 'OK' : 'ERR';
    _log(LogLevel.info,
        '$icon [$statusCode]: $url${body != null ? '\n   ${body.substring(0, body.length.clamp(0, 200))}' : ''}');
  }

  // ── Network Performance ─────────────────────────────────────
  static void networkTiming(String url, Duration duration, {int? bytes}) {
    if (!_enabled) return;
    final ms = duration.inMilliseconds;
    final size = bytes != null ? '${(bytes / 1024).toStringAsFixed(1)}KB' : '';
    _log(LogLevel.info, 'NET [${ms}ms] $url $size'.trim());
  }

  // ── Performance Timing ──────────────────────────────────────
  static final Map<String, Stopwatch> _timers = {};

  static void startTimer(String name) {
    if (!_enabled) return;
    _timers[name] = Stopwatch()..start();
  }

  static Duration stopTimer(String name) {
    final timer = _timers.remove(name);
    if (timer == null) return Duration.zero;
    timer.stop();
    final elapsed = timer.elapsed;
    _log(LogLevel.info,
        'PERF [$name]: ${elapsed.inMilliseconds}ms');
    return elapsed;
  }

  static void performance(String operation, Duration duration,
      {String? details}) {
    if (!_enabled) return;
    final ms = duration.inMilliseconds;
    _log(LogLevel.info,
        'PERF [$operation]: ${ms}ms${details != null ? ' ($details)' : ''}');
  }

  // ── Firebase ────────────────────────────────────────────────
  static void firebase(String operation, {String? collection, String? doc}) {
    if (!_enabled) return;
    _log(LogLevel.debug,
        'FIREBASE: $operation${collection != null ? ' [$collection${doc != null ? '/$doc' : ''}]' : ''}');
  }

  // ── Cache ───────────────────────────────────────────────────
  static void cache(String action, String key, {bool hit = false}) {
    if (!_enabled) return;
    final tag = hit ? 'HIT' : action.toUpperCase();
    _log(LogLevel.debug, 'CACHE $tag: $key');
  }

  // ── Session Tracking ────────────────────────────────────────
  static void session(String event, {Map<String, dynamic>? data}) {
    if (!_enabled) return;
    final entry = data != null ? '$event $data' : event;
    _log(LogLevel.info, 'SESSION: $entry');
  }

  // ── General ─────────────────────────────────────────────────
  static void debug(String msg) {
    if (_enabled && _minLevel.index <= LogLevel.debug.index) {
      _log(LogLevel.debug, msg);
    }
  }

  static void info(String msg) {
    if (_enabled && _minLevel.index <= LogLevel.info.index) {
      _log(LogLevel.info, msg);
    }
  }

  static void warning(String msg) {
    if (_enabled && _minLevel.index <= LogLevel.warning.index) {
      _log(LogLevel.warning, msg);
    }
  }

  // ── Errors ──────────────────────────────────────────────────
  static void error(String msg, {Object? exception, StackTrace? stack}) {
    if (!_enabled) return;
    _log(LogLevel.error, msg);
    if (exception != null) _log(LogLevel.error, '   Exception: $exception');
    if (stack != null && kDebugMode) {
      _log(LogLevel.error,
          '   Stack: ${stack.toString().split('\n').take(5).join('\n   ')}');
    }
  }

  // ── Zakat specific ──────────────────────────────────────────
  static void goldPrice(double price, String currency, String source) {
    if (!_enabled) return;
    _log(LogLevel.info, 'GOLD: $price $currency/gram [source: $source]');
  }

  static void nisab(double value, String currency, String method) {
    if (!_enabled) return;
    _log(LogLevel.info, 'NISAB: $value $currency [method: $method]');
  }

  static void zakat(double wealth, double zakat, String currency) {
    if (!_enabled) return;
    _log(LogLevel.info, 'ZAKAT: wealth=$wealth, due=$zakat $currency');
  }

  // ── Crashlytics Bridge ──────────────────────────────────────
  static void crashlyticsLog(String message) {
    if (!_enabled) return;
    _log(LogLevel.info, 'CRASHLYTICS: $message');
  }

  // ── internal ────────────────────────────────────────────────
  static void _log(LogLevel level, String msg) {
    final time = DateTime.now().toString().substring(11, 19);
    final prefix = _levelPrefix(level);
    final logLine = '[$time] $prefix $msg';

    // ignore: avoid_print
    print(logLine);

    // Store session logs
    if (_sessionLogs.length >= _maxSessionLogs) {
      _sessionLogs.removeAt(0);
    }
    _sessionLogs.add(logLine);
  }

  static String _levelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'D';
      case LogLevel.info:
        return 'I';
      case LogLevel.warning:
        return 'W';
      case LogLevel.error:
        return 'E';
    }
  }
}
