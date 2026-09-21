import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zakat_app/data/datasources/gemini_api_client.dart';
import 'package:zakat_app/domain/repositories/ai_chat_repository.dart';
import 'package:zakat_app/domain/usecases/send_ai_message.dart';
import 'package:zakat_app/presentation/features/ai_chat/ai_chat_view_model.dart';

class MockAiChatRepository extends Mock implements AiChatRepository {}

void main() {
  late MockAiChatRepository mockRepo;
  late SendAiMessageUseCase useCase;
  late AiChatViewModel viewModel;

  setUp(() {
    mockRepo = MockAiChatRepository();
    useCase = SendAiMessageUseCase(mockRepo);
    viewModel = AiChatViewModel(useCase);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('Full AI Chat Integration', () {
    test('complete flow: user sends message, gets AI reply', () async {
      when(() => mockRepo.hasApiKey).thenReturn(true);
      when(() => mockRepo.sendMessage(
            userText: any(named: 'userText'),
            systemPrompt: any(named: 'systemPrompt'),
          )).thenAnswer((_) async => 'Zakat is 2.5% of your wealth.');

      await viewModel.sendMessage(
        text: 'What is Zakat?',
        isArabic: false,
        totalWealth: 100000,
        zakatDue: 2500,
        goldPricePerGram: 300,
        goldNisab: 25500,
        hasReachedNisab: true,
        currency: 'USD',
      );

      expect(viewModel.messages.length, 2);
      expect(viewModel.messages[0].text, 'What is Zakat?');
      expect(viewModel.messages[0].isUser, isTrue);
      expect(viewModel.messages[1].text, 'Zakat is 2.5% of your wealth.');
      expect(viewModel.messages[1].isUser, isFalse);
      expect(viewModel.messages[1].isError, isFalse);
    });

    test('multi-turn conversation maintains history', () async {
      when(() => mockRepo.hasApiKey).thenReturn(true);
      when(() => mockRepo.sendMessage(
            userText: any(named: 'userText'),
            systemPrompt: any(named: 'systemPrompt'),
          )).thenAnswer((_) async => 'First reply');

      await viewModel.sendMessage(
        text: 'Question 1',
        isArabic: false,
        totalWealth: 0,
        zakatDue: 0,
        goldPricePerGram: 0,
        goldNisab: 0,
        hasReachedNisab: false,
        currency: 'USD',
      );

      when(() => mockRepo.sendMessage(
            userText: any(named: 'userText'),
            systemPrompt: any(named: 'systemPrompt'),
          )).thenAnswer((_) async => 'Second reply');

      await viewModel.sendMessage(
        text: 'Question 2',
        isArabic: false,
        totalWealth: 0,
        zakatDue: 0,
        goldPricePerGram: 0,
        goldNisab: 0,
        hasReachedNisab: false,
        currency: 'USD',
      );

      expect(viewModel.messages.length, 4);
      expect(viewModel.messages[0].text, 'Question 1');
      expect(viewModel.messages[1].text, 'First reply');
      expect(viewModel.messages[2].text, 'Question 2');
      expect(viewModel.messages[3].text, 'Second reply');
    });

    test('API error returns user-friendly message, not technical', () async {
      when(() => mockRepo.hasApiKey).thenReturn(true);
      when(() => mockRepo.sendMessage(
            userText: any(named: 'userText'),
            systemPrompt: any(named: 'systemPrompt'),
          )).thenThrow(AiChatException('invalid_request',
              cause: 'API key not valid'));

      await viewModel.sendMessage(
        text: 'Hello',
        isArabic: false,
        totalWealth: 0,
        zakatDue: 0,
        goldPricePerGram: 0,
        goldNisab: 0,
        hasReachedNisab: false,
        currency: 'USD',
      );

      final errorMsg = viewModel.messages[1];
      expect(errorMsg.isError, isTrue);
      // Must NOT contain technical details
      expect(errorMsg.text, isNot(contains('API key not valid')));
      expect(errorMsg.text, isNot(contains('invalid_request')));
      // Must contain friendly message
      expect(errorMsg.text, contains('Invalid request'));
    });

    test('rate limit error returns friendly message', () async {
      when(() => mockRepo.hasApiKey).thenReturn(true);
      when(() => mockRepo.sendMessage(
            userText: any(named: 'userText'),
            systemPrompt: any(named: 'systemPrompt'),
          )).thenThrow(AiChatException('rate_limit'));

      await viewModel.sendMessage(
        text: 'Hello',
        isArabic: false,
        totalWealth: 0,
        zakatDue: 0,
        goldPricePerGram: 0,
        goldNisab: 0,
        hasReachedNisab: false,
        currency: 'USD',
      );

      final errorMsg = viewModel.messages[1];
      expect(errorMsg.isError, isTrue);
      expect(errorMsg.text, isNot(contains('rate_limit')));
      expect(errorMsg.text, contains('Too many'));
    });

    test('network error returns friendly message', () async {
      when(() => mockRepo.hasApiKey).thenReturn(true);
      when(() => mockRepo.sendMessage(
            userText: any(named: 'userText'),
            systemPrompt: any(named: 'systemPrompt'),
          )).thenThrow(AiChatException('network_error'));

      await viewModel.sendMessage(
        text: 'Hello',
        isArabic: false,
        totalWealth: 0,
        zakatDue: 0,
        goldPricePerGram: 0,
        goldNisab: 0,
        hasReachedNisab: false,
        currency: 'USD',
      );

      final errorMsg = viewModel.messages[1];
      expect(errorMsg.isError, isTrue);
      expect(errorMsg.text, isNot(contains('network_error')));
      expect(errorMsg.text, contains('connect'));
    });

    test('blocked response (SAFETY) returns friendly error', () async {
      when(() => mockRepo.hasApiKey).thenReturn(true);
      when(() => mockRepo.sendMessage(
            userText: any(named: 'userText'),
            systemPrompt: any(named: 'systemPrompt'),
          )).thenThrow(AiChatException('empty_response'));

      await viewModel.sendMessage(
        text: 'test',
        isArabic: false,
        totalWealth: 0,
        zakatDue: 0,
        goldPricePerGram: 0,
        goldNisab: 0,
        hasReachedNisab: false,
        currency: 'USD',
      );

      final errorMsg = viewModel.messages[1];
      expect(errorMsg.isError, isTrue);
      expect(errorMsg.text, isNot(contains('empty_response')));
      expect(errorMsg.text, contains('No response'));
    });

    test('clearChat resets conversation', () async {
      when(() => mockRepo.hasApiKey).thenReturn(true);
      when(() => mockRepo.sendMessage(
            userText: any(named: 'userText'),
            systemPrompt: any(named: 'systemPrompt'),
          )).thenAnswer((_) async => 'Reply');

      await viewModel.sendMessage(
        text: 'Hello',
        isArabic: false,
        totalWealth: 0,
        zakatDue: 0,
        goldPricePerGram: 0,
        goldNisab: 0,
        hasReachedNisab: false,
        currency: 'USD',
      );

      expect(viewModel.messages.length, 2);

      when(() => mockRepo.clearHistory()).thenReturn(null);
      viewModel.clearChat();
      expect(viewModel.messages.length, 0);

      viewModel.addWelcome(false);
      expect(viewModel.messages.length, 1);
    });

    test('system prompt contains user wealth data', () async {
      when(() => mockRepo.hasApiKey).thenReturn(true);
      when(() => mockRepo.sendMessage(
            userText: any(named: 'userText'),
            systemPrompt: any(named: 'systemPrompt'),
          )).thenAnswer((_) async => 'OK');

      await viewModel.sendMessage(
        text: 'test',
        isArabic: false,
        totalWealth: 100000,
        zakatDue: 2500,
        goldPricePerGram: 300,
        goldNisab: 25500,
        hasReachedNisab: true,
        currency: 'USD',
      );

      final captured = verify(() => mockRepo.sendMessage(
            userText: any(named: 'userText'),
            systemPrompt: captureAny(named: 'systemPrompt'),
          )).captured;

      final systemPrompt = captured.last as String;
      expect(systemPrompt, contains('100000'));
      expect(systemPrompt, contains('2500'));
      expect(systemPrompt, contains('300'));
      expect(systemPrompt, contains('USD'));
      expect(systemPrompt, contains('Yes'));
    });

    test('Arabic system prompt is in Arabic', () async {
      when(() => mockRepo.hasApiKey).thenReturn(true);
      when(() => mockRepo.sendMessage(
            userText: any(named: 'userText'),
            systemPrompt: any(named: 'systemPrompt'),
          )).thenAnswer((_) async => 'OK');

      await viewModel.sendMessage(
        text: 'test',
        isArabic: true,
        totalWealth: 50000,
        zakatDue: 1250,
        goldPricePerGram: 285,
        goldNisab: 24225,
        hasReachedNisab: true,
        currency: 'LYD',
      );

      final captured = verify(() => mockRepo.sendMessage(
            userText: any(named: 'userText'),
            systemPrompt: captureAny(named: 'systemPrompt'),
          )).captured;

      final systemPrompt = captured.last as String;
      expect(systemPrompt, contains('مساعد ذكي'));
      expect(systemPrompt, contains('50000'));
      expect(systemPrompt, contains('نعم'));
    });

    test('generic exception shows friendly message not stack trace', () async {
      when(() => mockRepo.hasApiKey).thenReturn(true);
      when(() => mockRepo.sendMessage(
            userText: any(named: 'userText'),
            systemPrompt: any(named: 'systemPrompt'),
          )).thenThrow(Exception('Something unexpected'));

      await viewModel.sendMessage(
        text: 'test',
        isArabic: false,
        totalWealth: 0,
        zakatDue: 0,
        goldPricePerGram: 0,
        goldNisab: 0,
        hasReachedNisab: false,
        currency: 'USD',
      );

      final errorMsg = viewModel.messages[1];
      expect(errorMsg.isError, isTrue);
      expect(errorMsg.text, isNot(contains('Something unexpected')));
      expect(errorMsg.text, isNot(contains('Exception')));
      expect(errorMsg.text, contains('temporarily unavailable'));
    });
  });
}
