// ================================================================
// services/connectivity_service.dart — Offline Mode (بند 15)
// يراقب الاتصال ويُحدِّث التطبيق تلقائياً عند عودة الإنترنت
// ================================================================
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

enum ConnectivityStatus { online, offline, unknown }

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;
  ConnectivityService._();

  ConnectivityStatus _status = ConnectivityStatus.unknown;
  Timer? _pollingTimer;
  DateTime? _lastOnlineAt;

  ConnectivityStatus get status => _status;
  bool get isOnline => _status == ConnectivityStatus.online;
  bool get isOffline => _status == ConnectivityStatus.offline;
  DateTime? get lastOnlineAt => _lastOnlineAt;

  // ── Stream للاستماع لتغيرات الاتصال ──────────────────────────
  final _controller = StreamController<ConnectivityStatus>.broadcast();
  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  // ── تهيئة — استدعِ في main() أو ZakatProvider.init() ─────────
  Future<void> init() async {
    await _check();
    // فحص كل 15 ثوانٍ (أقل استهلاكاً)
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _check(),
    );
  }

  Future<void> _check() async {
    final prev = _status;
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _status = ConnectivityStatus.online;
        _lastOnlineAt = DateTime.now();
      }
    } on SocketException {
      _status = ConnectivityStatus.offline;
    } on TimeoutException {
      _status = ConnectivityStatus.offline;
    } catch (_) {
      _status = ConnectivityStatus.offline;
    }

    if (_status != prev) {
      notifyListeners();
      _controller.add(_status);
      if (kDebugMode) {
        print('[ConnectivityService] Status: $_status');
      }
    }
  }

  // ── فرض فحص فوري ─────────────────────────────────────────────
  Future<void> checkNow() => _check();

  // ── انتظر حتى يعود الإنترنت ──────────────────────────────────
  Future<void> waitForConnection(
      {Duration timeout = const Duration(minutes: 2)}) async {
    if (isOnline) return;
    await _controller.stream
        .firstWhere((s) => s == ConnectivityStatus.online)
        .timeout(timeout, onTimeout: () => ConnectivityStatus.offline);
  }

  // ── وصف الحالة ────────────────────────────────────────────────
  String statusText(bool isArabic) {
    switch (_status) {
      case ConnectivityStatus.online:
        return isArabic ? '✅ متصل بالإنترنت' : '✅ Online';
      case ConnectivityStatus.offline:
        return isArabic
            ? '📴 لا يوجد إنترنت — يعمل من الكاش'
            : '📴 Offline — using cached data';
      case ConnectivityStatus.unknown:
        return isArabic ? '🔄 جاري التحقق...' : '🔄 Checking...';
    }
  }

  String? offlineSince(bool isArabic) {
    if (isOnline || _lastOnlineAt == null) return null;
    final diff = DateTime.now().difference(_lastOnlineAt!);
    if (diff.inMinutes < 1) {
      return isArabic ? 'منذ لحظات' : 'just now';
    }
    if (diff.inHours < 1) {
      return isArabic
          ? 'منذ ${diff.inMinutes} دقيقة'
          : '${diff.inMinutes}m ago';
    }
    return isArabic ? 'منذ ${diff.inHours} ساعة' : '${diff.inHours}h ago';
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _controller.close();
    super.dispose();
  }
}
