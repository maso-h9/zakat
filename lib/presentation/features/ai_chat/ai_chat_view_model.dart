import 'package:flutter/foundation.dart';
import '../../../domain/usecases/send_ai_message.dart';
import '../../../domain/entities/ai_message.dart';
import '../../../data/datasources/ai_prompt_builder.dart';
import '../../../data/datasources/gemini_api_client.dart';
import '../../../core/utils/app_logger.dart';

class AiChatViewModel extends ChangeNotifier {
  final SendAiMessageUseCase _sendMessageUseCase;

  AiChatViewModel(this._sendMessageUseCase);

  final List<AiMessage> _messages = [];
  bool _isLoading = false;
  bool _welcomeAdded = false;

  List<AiMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get hasApiKey => _sendMessageUseCase.hasApiKey;

  void addWelcome(bool isArabic) {
    if (_welcomeAdded) return;
    _welcomeAdded = true;
    _messages.add(AiMessage(
      text: AiPromptBuilder.welcomeMessage(isArabic),
      isUser: false,
    ));
  }

  Future<void> sendMessage({
    required String text,
    required bool isArabic,
    required double totalWealth,
    required double zakatDue,
    required double goldPricePerGram,
    required double goldNisab,
    required bool hasReachedNisab,
    required String currency,
  }) async {
    if (text.trim().isEmpty || _isLoading) return;

    _messages.add(AiMessage(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      final systemPrompt = AiPromptBuilder.buildSystemPrompt(
        isArabic: isArabic,
        totalWealth: totalWealth,
        zakatDue: zakatDue,
        goldPricePerGram: goldPricePerGram,
        goldNisab: goldNisab,
        hasReachedNisab: hasReachedNisab,
        currency: currency,
      );

      final reply = await _sendMessageUseCase.execute(
        userText: text,
        systemPrompt: systemPrompt,
      );

      _messages.add(AiMessage(text: reply, isUser: false));
    } catch (e) {
      AppLogger.error('AiChatViewModel: send failed', exception: e);

      String friendlyMessage;
      if (e is AiChatException) {
        friendlyMessage = e.messageForLanguage(isArabic);
      } else {
        friendlyMessage = _defaultUserMessage(isArabic);
      }

      _messages.add(AiMessage(
        text: friendlyMessage,
        isUser: false,
        isError: true,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _sendMessageUseCase.clearHistory();
    _welcomeAdded = false;
    notifyListeners();
  }

  static List<String> suggestions(bool isArabic) =>
      AiPromptBuilder.suggestions(isArabic);

  static String _defaultUserMessage(bool isArabic) => isArabic
      ? 'عذراً، المساعد الذكي غير متاح حالياً. حاول مرة أخرى بعد قليل.'
      : 'Sorry, the AI assistant is temporarily unavailable. Please try again in a moment.';
}
