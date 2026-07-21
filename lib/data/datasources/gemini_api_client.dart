import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../core/utils/app_logger.dart';

class GeminiApiClient {
  final String apiKey;

  static const String _model = 'gemini-2.0-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';
  static const int _maxHistory = 20;
  static const int _maxRetries = 2;
  static const Duration _baseTimeout = Duration(seconds: 60);

  final List<Map<String, dynamic>> _history = [];

  GeminiApiClient({required this.apiKey});

  bool get hasApiKey => apiKey.isNotEmpty && apiKey != 'YOUR_GEMINI_API_KEY';

  String get effectiveKey => apiKey;

  Future<String> sendMessage({
    required String userText,
    required String systemPrompt,
  }) async {
    if (!hasApiKey) throw AiChatException('api_key_missing');

    _history.add({
      'role': 'user',
      'parts': [
        {'text': userText}
      ],
    });

    return _sendWithRetry(systemPrompt);
  }

  Future<String> _sendWithRetry(String systemPrompt) async {
    int attempt = 0;
    while (attempt <= _maxRetries) {
      try {
        final url = '$_baseUrl?key=$apiKey';
        AppLogger.request('Gemini [attempt ${attempt + 1}/$_maxRetries]: $_model');

        final response = await http
            .post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': _history,
                'systemInstruction': {
                  'parts': [
                    {'text': systemPrompt}
                  ],
                },
                'generationConfig': {
                  'maxOutputTokens': 1500,
                  'temperature': 0.7,
                },
              }),
            )
            .timeout(_baseTimeout);

        AppLogger.response('Gemini', response.statusCode);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final reply = _parseText(data);
          if (reply == null) {
            final msg = _parseError(data);
            throw AiChatException('empty_response',
                cause: msg ?? 'Empty or blocked response');
          }

          _history.add({
            'role': 'model',
            'parts': [
              {'text': reply}
            ],
          });

          if (_history.length > _maxHistory) {
            _history.removeRange(0, _history.length - _maxHistory);
          }

          return reply;
        }

        // Parse error body for all non-200 responses
        Map<String, dynamic>? body;
        try {
          body = jsonDecode(response.body) as Map<String, dynamic>?;
        } catch (_) {
          body = null;
        }
        final errorMsg = body?['error']?['message'] as String?;
        final errorStatus = body?['error']?['status'] as String?;
        AppLogger.warning(
            'Gemini HTTP ${response.statusCode}: ${errorMsg ?? response.body.substring(0, min(200, response.body.length))}');

        // Retryable: 429 (rate limit) and 503 (service unavailable)
        if (response.statusCode == 429 || response.statusCode == 503) {
          if (attempt < _maxRetries) {
            final delay =
                Duration(milliseconds: 1000 * pow(2, attempt).toInt());
            AppLogger.warning(
                'Gemini: ${response.statusCode} — retrying in ${delay.inMilliseconds}ms');
            await Future.delayed(delay);
            attempt++;
            continue;
          }
        }

        // Non-retryable errors
        if (response.statusCode == 429 ||
            errorStatus == 'RESOURCE_EXHAUSTED') {
          throw AiChatException('rate_limit');
        }
        if (response.statusCode == 400) {
          throw AiChatException('invalid_request',
              cause: errorMsg ?? 'Bad request');
        }
        if (response.statusCode == 404) {
          throw AiChatException('model_not_found',
              cause: errorMsg ?? 'Model not found');
        }
        if (response.statusCode == 403) {
          throw AiChatException('forbidden',
              cause: errorMsg ?? 'API key lacks permission');
        }
        if (response.statusCode == 503) {
          throw AiChatException('service_unavailable');
        }

        throw AiChatException('http_error',
            cause: 'HTTP ${response.statusCode}: ${errorMsg ?? "Unknown error"}');
      } on AiChatException {
        if (_history.isNotEmpty && _history.last['role'] == 'user') {
          _history.removeLast();
        }
        rethrow;
      } catch (e) {
        if (attempt < _maxRetries &&
            (e.toString().contains('SocketException') ||
                e.toString().contains('TimeoutException') ||
                e.toString().contains('Connection'))) {
          final delay =
              Duration(milliseconds: 1000 * pow(2, attempt).toInt());
          AppLogger.warning(
              'Gemini: network error — retrying in ${delay.inMilliseconds}ms');
          await Future.delayed(delay);
          attempt++;
          continue;
        }
        if (_history.isNotEmpty && _history.last['role'] == 'user') {
          _history.removeLast();
        }
        AppLogger.error('GeminiApiClient: error', exception: e);
        throw AiChatException('network_error', cause: e.toString());
      }
    }

    throw AiChatException('max_retries');
  }

  String? _parseText(Map<String, dynamic> json) {
    try {
      final candidates = json['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) return null;

      final candidate = candidates[0] as Map<String, dynamic>;
      final finishReason = candidate['finishReason'] as String?;
      if (finishReason == 'SAFETY' || finishReason == 'RECITATION') {
        AppLogger.warning('Gemini: blocked ($finishReason)');
        return null;
      }

      final parts = candidate['content']?['parts'] as List?;
      if (parts == null || parts.isEmpty) return null;
      final text = parts[0]['text'] as String?;
      return text?.trim().isEmpty == true ? null : text;
    } catch (e) {
      AppLogger.error('Gemini: parse error', exception: e);
      return null;
    }
  }

  String? _parseError(Map<String, dynamic>? body) {
    if (body == null) return null;
    return body['error']?['message'] as String?;
  }

  void clearHistory() => _history.clear();
}

class AiChatException implements Exception {
  final String code;
  final String? cause;

  AiChatException(this.code, {this.cause});

  String get userMessage => _messages[code] ?? 'حدث خطأ في المساعد الذكي. حاول مجدداً.';

  static const Map<String, String> _messages = {
    'api_key_missing':
        'يجب إضافة مفتاح Gemini API للمساعد الذكي.\nاحصل عليه مجاناً من: https://aistudio.google.com/app/apikey',
    'rate_limit': 'تجاوزت الحد المسموح من الطلبات. حاول بعد دقيقة.',
    'invalid_request': 'خطأ في الطلب. تحقق من إعدادات API.',
    'invalid_key': 'مفتاح API غير صحيح أو منتهي الصلاحية.',
    'model_not_found': 'النموذج المطلوب غير متاح. تحقق من إعدادات Gemini.',
    'forbidden': 'المفتاح غير مصرح له باستخدام هذا النموذج.',
    'empty_response': 'لم يصلني رد من المساعد. حاول مجدداً.',
    'service_unavailable': 'خدمة Gemini غير متاحة حالياً. حاول لاحقاً.',
    'network_error': 'تعذّر الاتصال بالمساعد. تحقق من الإنترنت.',
    'max_retries':
        'تعذّر الاتصال بالمساعد بعد عدة محاولات. حاول لاحقاً.',
    'http_error': 'خطأ غير متوقع في الخادم. حاول مجدداً.',
  };

  @override
  String toString() =>
      'AiChatException: $code${cause != null ? ' ($cause)' : ''}';
}
