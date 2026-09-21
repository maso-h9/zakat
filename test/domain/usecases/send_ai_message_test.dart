import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zakat_app/data/datasources/gemini_api_client.dart';
import 'package:zakat_app/domain/repositories/ai_chat_repository.dart';
import 'package:zakat_app/domain/usecases/send_ai_message.dart';

class MockAiChatRepository extends Mock implements AiChatRepository {}

void main() {
  late MockAiChatRepository mockRepo;
  late SendAiMessageUseCase useCase;

  setUp(() {
    mockRepo = MockAiChatRepository();
    useCase = SendAiMessageUseCase(mockRepo);
  });

  group('SendAiMessageUseCase', () {
    group('hasApiKey', () {
      test('delegates to repository', () {
        when(() => mockRepo.hasApiKey).thenReturn(true);
        expect(useCase.hasApiKey, isTrue);
      });

      test('returns false when repo has no key', () {
        when(() => mockRepo.hasApiKey).thenReturn(false);
        expect(useCase.hasApiKey, isFalse);
      });
    });

    group('execute', () {
      test('returns reply from repository', () async {
        when(() => mockRepo.sendMessage(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenAnswer((_) async => 'Zakat is 2.5% of wealth.');

        final result = await useCase.execute(
          userText: 'What is Zakat?',
          systemPrompt: 'You are a Zakat expert.',
        );

        expect(result, 'Zakat is 2.5% of wealth.');
        verify(() => mockRepo.sendMessage(
              userText: 'What is Zakat?',
              systemPrompt: 'You are a Zakat expert.',
            )).called(1);
      });

      test('propagates AiChatException', () async {
        when(() => mockRepo.sendMessage(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenThrow(AiChatException('empty_response'));

        expect(
          () => useCase.execute(
            userText: 'test',
            systemPrompt: 'prompt',
          ),
          throwsA(isA<AiChatException>().having(
            (e) => e.code,
            'code',
            'empty_response',
          )),
        );
      });

      test('propagates generic exceptions', () async {
        when(() => mockRepo.sendMessage(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenThrow(Exception('unexpected'));

        expect(
          () => useCase.execute(
            userText: 'test',
            systemPrompt: 'prompt',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('clearHistory', () {
      test('delegates to repository', () {
        when(() => mockRepo.clearHistory()).thenReturn(null);
        useCase.clearHistory();
        verify(() => mockRepo.clearHistory()).called(1);
      });
    });
  });
}
