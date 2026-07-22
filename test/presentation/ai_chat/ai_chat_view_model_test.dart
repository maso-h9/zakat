import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zakat_app/data/datasources/gemini_api_client.dart';
import 'package:zakat_app/domain/usecases/send_ai_message.dart';
import 'package:zakat_app/presentation/features/ai_chat/ai_chat_view_model.dart';

class MockSendAiMessageUseCase extends Mock implements SendAiMessageUseCase {}

void main() {
  late MockSendAiMessageUseCase mockUseCase;
  late AiChatViewModel viewModel;

  setUp(() {
    mockUseCase = MockSendAiMessageUseCase();
    viewModel = AiChatViewModel(mockUseCase);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('AiChatViewModel', () {
    group('initial state', () {
      test('messages is empty', () {
        expect(viewModel.messages, isEmpty);
      });

      test('isLoading is false', () {
        expect(viewModel.isLoading, isFalse);
      });
    });

    group('hasApiKey', () {
      test('delegates to use case', () {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        expect(viewModel.hasApiKey, isTrue);
      });

      test('returns false when no key', () {
        when(() => mockUseCase.hasApiKey).thenReturn(false);
        expect(viewModel.hasApiKey, isFalse);
      });
    });

    group('addWelcome', () {
      test('adds welcome message in Arabic', () {
        viewModel.addWelcome(true);
        expect(viewModel.messages.length, 1);
        expect(viewModel.messages.first.isUser, isFalse);
        expect(viewModel.messages.first.text, contains('السلام عليكم'));
      });

      test('adds welcome message in English', () {
        viewModel.addWelcome(false);
        expect(viewModel.messages.length, 1);
        expect(viewModel.messages.first.isUser, isFalse);
        expect(viewModel.messages.first.text, contains('Hello'));
      });

      test('only adds welcome once', () {
        viewModel.addWelcome(true);
        viewModel.addWelcome(true);
        expect(viewModel.messages.length, 1);
      });

      test('can add welcome after clearChat', () {
        viewModel.addWelcome(true);
        viewModel.clearChat();
        viewModel.addWelcome(true);
        expect(viewModel.messages.length, 1);
      });
    });

    group('sendMessage - success', () {
      test('adds user message and AI reply', () async {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        when(() => mockUseCase.execute(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenAnswer((_) async => 'Zakat is 2.5%.');

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
        expect(viewModel.messages[0].isUser, isTrue);
        expect(viewModel.messages[0].text, 'What is Zakat?');
        expect(viewModel.messages[1].isUser, isFalse);
        expect(viewModel.messages[1].text, 'Zakat is 2.5%.');
        expect(viewModel.messages[1].isError, isFalse);
      });

      test('isLoading is false after completion', () async {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        when(() => mockUseCase.execute(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenAnswer((_) async => 'Reply');

        await viewModel.sendMessage(
          text: 'Hi',
          isArabic: false,
          totalWealth: 0,
          zakatDue: 0,
          goldPricePerGram: 0,
          goldNisab: 0,
          hasReachedNisab: false,
          currency: 'USD',
        );

        expect(viewModel.isLoading, isFalse);
      });

      test('notifies listeners on state change', () async {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        when(() => mockUseCase.execute(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenAnswer((_) async => 'Reply');

        final notifications = <bool>[];
        viewModel.addListener(() {
          notifications.add(viewModel.isLoading);
        });

        await viewModel.sendMessage(
          text: 'Hi',
          isArabic: false,
          totalWealth: 0,
          zakatDue: 0,
          goldPricePerGram: 0,
          goldNisab: 0,
          hasReachedNisab: false,
          currency: 'USD',
        );

        expect(notifications, contains(true)); // loading started
        expect(notifications, contains(false)); // loading ended
      });
    });

    group('sendMessage - error handling (user-friendly messages)', () {
      test('shows user-friendly message for AiChatException, not technical code',
          () async {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        when(() => mockUseCase.execute(
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

        expect(viewModel.messages.length, 2);
        final errorMsg = viewModel.messages[1];
        expect(errorMsg.isError, isTrue);
        expect(errorMsg.isUser, isFalse);
        // Must NOT expose 'rate_limit' to user
        expect(errorMsg.text, isNot(contains('rate_limit')));
        expect(errorMsg.text, isNot(contains('AiChatException')));
        // Must contain user-friendly English message
        expect(errorMsg.text, contains('Too many'));
      });

      test('shows Arabic user-friendly message when isArabic=true', () async {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        when(() => mockUseCase.execute(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenThrow(AiChatException('network_error'));

        await viewModel.sendMessage(
          text: 'مرحبا',
          isArabic: true,
          totalWealth: 0,
          zakatDue: 0,
          goldPricePerGram: 0,
          goldNisab: 0,
          hasReachedNisab: false,
          currency: 'LYD',
        );

        final errorMsg = viewModel.messages[1];
        expect(errorMsg.isError, isTrue);
        // Must NOT expose 'network_error' to user
        expect(errorMsg.text, isNot(contains('network_error')));
        // Must contain Arabic user-friendly message
        expect(errorMsg.text, contains('تعذّر'));
      });

      test('hides technical error for api_key_missing', () async {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        when(() => mockUseCase.execute(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenThrow(AiChatException('api_key_missing'));

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
        expect(errorMsg.text, isNot(contains('api_key_missing')));
        expect(errorMsg.text, contains('Gemini API'));
      });

      test('hides technical error for service_unavailable', () async {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        when(() => mockUseCase.execute(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenThrow(AiChatException('service_unavailable'));

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
        expect(errorMsg.text, isNot(contains('service_unavailable')));
        expect(errorMsg.text, contains('temporarily unavailable'));
      });

      test('hides technical error for empty_response', () async {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        when(() => mockUseCase.execute(
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
        expect(errorMsg.text, isNot(contains('empty_response')));
        expect(errorMsg.text, contains('No response'));
      });

      test('shows generic friendly message for non-AiChatException', () async {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        when(() => mockUseCase.execute(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenThrow(Exception('Something went wrong'));

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
        // Must NOT expose raw exception text
        expect(errorMsg.text, isNot(contains('Something went wrong')));
        expect(errorMsg.text, isNot(contains('Exception')));
        // Must show friendly message
        expect(errorMsg.text, contains('temporarily unavailable'));
      });

      test('shows Arabic generic message for non-AiChatException', () async {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        when(() => mockUseCase.execute(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenThrow(Exception('Something went wrong'));

        await viewModel.sendMessage(
          text: 'test',
          isArabic: true,
          totalWealth: 0,
          zakatDue: 0,
          goldPricePerGram: 0,
          goldNisab: 0,
          hasReachedNisab: false,
          currency: 'LYD',
        );

        final errorMsg = viewModel.messages[1];
        expect(errorMsg.text, isNot(contains('Exception')));
        expect(errorMsg.text, contains('المساعد الذكي غير متاح'));
      });

      test('isLoading is false after error', () async {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        when(() => mockUseCase.execute(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenThrow(AiChatException('network_error'));

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

        expect(viewModel.isLoading, isFalse);
      });

      test('no HTTP status codes exposed to user', () async {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        when(() => mockUseCase.execute(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenThrow(AiChatException('http_error', cause: 'HTTP 500'));

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
        expect(errorMsg.text, isNot(contains('HTTP 500')));
        expect(errorMsg.text, isNot(contains('500')));
      });

      test('no stack traces exposed to user', () async {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        when(() => mockUseCase.execute(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenThrow(AiChatException('network_error',
                cause: 'SocketException: Connection refused'));

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
        expect(errorMsg.text, isNot(contains('SocketException')));
        expect(errorMsg.text, isNot(contains('Connection refused')));
      });
    });

    group('sendMessage - edge cases', () {
      test('ignores empty text', () async {
        await viewModel.sendMessage(
          text: '',
          isArabic: false,
          totalWealth: 0,
          zakatDue: 0,
          goldPricePerGram: 0,
          goldNisab: 0,
          hasReachedNisab: false,
          currency: 'USD',
        );

        expect(viewModel.messages, isEmpty);
        verifyNever(() => mockUseCase.execute(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            ));
      });

      test('ignores whitespace-only text', () async {
        await viewModel.sendMessage(
          text: '   ',
          isArabic: false,
          totalWealth: 0,
          zakatDue: 0,
          goldPricePerGram: 0,
          goldNisab: 0,
          hasReachedNisab: false,
          currency: 'USD',
        );

        expect(viewModel.messages, isEmpty);
      });

      test('ignores send while loading', () async {
        when(() => mockUseCase.hasApiKey).thenReturn(true);
        when(() => mockUseCase.execute(
              userText: any(named: 'userText'),
              systemPrompt: any(named: 'systemPrompt'),
            )).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 1));
          return 'Reply';
        });

        // Start first send
        final future1 = viewModel.sendMessage(
          text: 'First',
          isArabic: false,
          totalWealth: 0,
          zakatDue: 0,
          goldPricePerGram: 0,
          goldNisab: 0,
          hasReachedNisab: false,
          currency: 'USD',
        );

        // Try second send while loading
        await viewModel.sendMessage(
          text: 'Second',
          isArabic: false,
          totalWealth: 0,
          zakatDue: 0,
          goldPricePerGram: 0,
          goldNisab: 0,
          hasReachedNisab: false,
          currency: 'USD',
        );

        await future1;

        // Only first message should be sent
        expect(viewModel.messages.length, 2); // user + reply
        expect(viewModel.messages[0].text, 'First');
      });
    });

    group('clearChat', () {
      test('clears all messages', () {
        viewModel.addWelcome(true);
        viewModel.clearChat();
        expect(viewModel.messages, isEmpty);
      });

      test('calls clearHistory on use case', () {
        when(() => mockUseCase.clearHistory()).thenReturn(null);
        viewModel.clearChat();
        verify(() => mockUseCase.clearHistory()).called(1);
      });

      test('allows adding welcome again after clear', () {
        viewModel.addWelcome(true);
        expect(viewModel.messages.length, 1);

        viewModel.clearChat();
        expect(viewModel.messages.length, 0);

        viewModel.addWelcome(true);
        expect(viewModel.messages.length, 1);
      });
    });

    group('suggestions', () {
      test('returns Arabic suggestions', () {
        final s = AiChatViewModel.suggestions(true);
        expect(s, isNotEmpty);
        expect(s.length, 4);
      });

      test('returns English suggestions', () {
        final s = AiChatViewModel.suggestions(false);
        expect(s, isNotEmpty);
        expect(s.length, 4);
      });
    });
  });
}
