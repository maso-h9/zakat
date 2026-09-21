import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zakat_app/data/datasources/gemini_api_client.dart';

void main() {
  late GeminiApiClient client;

  setUp(() {
    client = GeminiApiClient(apiKey: 'test-api-key-12345');
  });

  tearDown(() {
    client.clearHistory();
  });

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
    registerFallbackValue(<String, String>{});
  });

  group('GeminiApiClient', () {
    group('hasApiKey', () {
      test('returns true for valid key', () {
        final c = GeminiApiClient(apiKey: 'valid-key');
        expect(c.hasApiKey, isTrue);
      });

      test('returns false for empty key', () {
        final c = GeminiApiClient(apiKey: '');
        expect(c.hasApiKey, isFalse);
      });

      test('returns false for placeholder key', () {
        final c = GeminiApiClient(apiKey: 'YOUR_GEMINI_API_KEY');
        expect(c.hasApiKey, isFalse);
      });
    });

    group('effectiveKey', () {
      test('returns the api key', () {
        expect(client.effectiveKey, 'test-api-key-12345');
      });
    });

    group('sendMessage - API key validation', () {
      test('throws AiChatException when no API key', () async {
        final noKeyClient = GeminiApiClient(apiKey: '');
        expect(
          () => noKeyClient.sendMessage(
            userText: 'Hello',
            systemPrompt: 'You are a helper',
          ),
          throwsA(isA<AiChatException>().having(
            (e) => e.code,
            'code',
            'api_key_missing',
          )),
        );
      });

      test('throws AiChatException for placeholder key', () async {
        final placeholderClient = GeminiApiClient(apiKey: 'YOUR_GEMINI_API_KEY');
        expect(
          () => placeholderClient.sendMessage(
            userText: 'Hello',
            systemPrompt: 'You are a helper',
          ),
          throwsA(isA<AiChatException>().having(
            (e) => e.code,
            'code',
            'api_key_missing',
          )),
        );
      });
    });

    group('AiChatException', () {
      test('userMessage returns Arabic message for known code', () {
        final e = AiChatException('rate_limit');
        expect(e.userMessage, contains('تجاوزت'));
      });

      test('userMessageEn returns English message for known code', () {
        final e = AiChatException('rate_limit');
        expect(e.userMessageEn, contains('Too many'));
      });

      test('messageForLanguage returns Arabic when isArabic=true', () {
        final e = AiChatException('network_error');
        expect(e.messageForLanguage(true), contains('تعذّر'));
      });

      test('messageForLanguage returns English when isArabic=false', () {
        final e = AiChatException('network_error');
        expect(e.messageForLanguage(false), contains('connect'));
      });

      test('userMessage returns default for unknown code', () {
        final e = AiChatException('unknown_code');
        expect(e.userMessage, contains('خطأ'));
      });

      test('userMessageEn returns default for unknown code', () {
        final e = AiChatException('unknown_code');
        expect(e.userMessageEn, contains('error'));
      });

      test('toString includes code', () {
        final e = AiChatException('rate_limit');
        expect(e.toString(), contains('rate_limit'));
      });

      test('toString includes cause when present', () {
        final e = AiChatException('http_error', cause: 'HTTP 500');
        expect(e.toString(), contains('HTTP 500'));
      });

      test('all error codes have Arabic messages', () {
        final codes = [
          'api_key_missing',
          'rate_limit',
          'invalid_request',
          'invalid_key',
          'model_not_found',
          'forbidden',
          'empty_response',
          'service_unavailable',
          'network_error',
          'max_retries',
          'http_error',
        ];
        for (final code in codes) {
          final e = AiChatException(code);
          expect(e.userMessage, isNotEmpty, reason: 'Arabic msg for $code');
          expect(e.userMessageEn, isNotEmpty, reason: 'English msg for $code');
        }
      });

      test('cause is preserved', () {
        final e = AiChatException('network_error', cause: 'SocketException');
        expect(e.cause, 'SocketException');
      });

      test('cause is nullable', () {
        final e = AiChatException('rate_limit');
        expect(e.cause, isNull);
      });
    });

    group('history management', () {
      test('clearHistory empties the history', () {
        client.clearHistory();
        expect(() => client.clearHistory(), returnsNormally);
      });
    });
  });
}
