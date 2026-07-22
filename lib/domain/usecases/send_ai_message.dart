import '../repositories/ai_chat_repository.dart';

class SendAiMessageUseCase {
  final AiChatRepository _repo;

  SendAiMessageUseCase(this._repo);

  bool get hasApiKey => _repo.hasApiKey;

  Future<String> execute({
    required String userText,
    required String systemPrompt,
  }) {
    return _repo.sendMessage(userText: userText, systemPrompt: systemPrompt);
  }

  void clearHistory() => _repo.clearHistory();
}
