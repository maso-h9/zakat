import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zakat_app/data/datasources/gemini_api_client.dart';
import 'package:zakat_app/data/repositories_impl/ai_chat_repository_impl.dart';

class MockGeminiApiClient extends Mock implements GeminiApiClient {}

void main() {
  late MockGeminiApiClient mockClient;
  late AiChatRepositoryImpl repository;

  setUp(() {
    mockClient = MockGeminiApiClient();
    repository = AiChatRepositoryImpl(mockClient);
  });

  group('AiChatRepositoryImpl', () {
    group('hasApiKey', () {
      test('delegates to client hasApiKey', () {
        when(() => mockClient.hasApiKey).thenReturn(true);
        expect(repository.hasApiKey, isTrue);
      });

      test('returns false when client has no key', () {
        when(() => mockClient.hasApiKey).thenReturn(false);
        expect(repository.hasApiKey, isFalse);
      });
    });

    group('sendMessage', () {
      test('delegates to client and returns response', () async {
        when(() => mockClient.sendMessage(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenAnswer((_) async => 'Hello from Gemini!');

        final result = await repository.sendMessage(
          userText: 'Hi',
          systemPrompt: 'You are helpful',
        );

        expect(result, 'Hello from Gemini!');
        verify(() => mockClient.sendMessage(
              userText: 'Hi',
              systemPrompt: 'You are helpful',
            )).called(1);
      });

      test('propagates exceptions from client', () async {
        when(() => mockClient.sendMessage(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenThrow(AiChatException('rate_limit'));

        expect(
          () => repository.sendMessage(
            userText: 'Hi',
            systemPrompt: 'prompt',
          ),
          throwsA(isA<AiChatException>().having(
            (e) => e.code,
            'code',
            'rate_limit',
          )),
        );
      });

      test('propagates network errors', () async {
        when(() => mockClient.sendMessage(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenThrow(AiChatException('network_error'));

        expect(
          () => repository.sendMessage(
            userText: 'test',
            systemPrompt: 'prompt',
          ),
          throwsA(isA<AiChatException>().having(
            (e) => e.code,
            'code',
            'network_error',
          )),
        );
      });
    });

    group('clearHistory', () {
      test('delegates to client clearHistory', () {
        when(() => mockClient.clearHistory()).thenReturn(null);
        repository.clearHistory();
        verify(() => mockClient.clearHistory()).called(1);
      });
    });
  });
}
