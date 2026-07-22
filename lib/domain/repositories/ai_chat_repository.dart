abstract class AiChatRepository {
  bool get hasApiKey;
  Future<String> sendMessage({
    required String userText,
    required String systemPrompt,
  });
  void clearHistory();
}
