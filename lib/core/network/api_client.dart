// ================================================================
// core/network/api_client.dart — طبقة API موحّدة (بند 16)
// Retry · Timeout · Logger · Unified Error Parsing
// ================================================================
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../errors/app_exception.dart';
import '../utils/app_logger.dart';

class ApiClient {
  static const Duration _defaultTimeout = Duration(seconds: 10);
  static const int _maxRetries = 2;

  /// GET مع retry تلقائي وlogging
  static Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
    int maxRetries = _maxRetries,
  }) async {
    AppLogger.request(url);
    Object? lastError;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response =
            await http.get(Uri.parse(url), headers: headers).timeout(timeout);

        AppLogger.response(url, response.statusCode, body: response.body);

        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }

        if (response.statusCode == 429) {
          // Rate limit — انتظر وحاول مرة أخرى
          if (attempt < maxRetries) {
            await Future.delayed(Duration(seconds: (attempt + 1) * 2));
            continue;
          }
        }

        throw ApiException(url, statusCode: response.statusCode);
      } on SocketException catch (e) {
        lastError = e;
        AppLogger.warning('[$attempt] Network error: $e');
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt + 1));
        }
      } on TimeoutException {
        lastError = const TimeoutException();
        AppLogger.warning('[$attempt] Timeout: $url');
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(seconds: 2));
        }
      } on ApiException {
        rethrow;
      } catch (e) {
        lastError = e;
        AppLogger.error('[$attempt] Unexpected error: $e');
        break;
      }
    }

    throw toAppException(lastError ?? UnknownException());
  }

  /// GET يعيد List بدل Map
  static Future<List<dynamic>> getList(
    String url, {
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
  }) async {
    AppLogger.request(url);
    try {
      final response =
          await http.get(Uri.parse(url), headers: headers).timeout(timeout);

      AppLogger.response(url, response.statusCode);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return decoded;
        if (decoded is Map) return [decoded]; // بعض APIs ترجع Map
      }
      throw ApiException(url, statusCode: response.statusCode);
    } on SocketException catch (e) {
      throw NetworkException(cause: e.toString());
    } catch (e) {
      throw toAppException(e);
    }
  }
}
