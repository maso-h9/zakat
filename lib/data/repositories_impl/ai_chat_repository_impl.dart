import '../../domain/repositories/ai_chat_repository.dart';
import '../datasources/gemini_api_client.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  final GeminiApiClient _client;

  AiChatRepositoryImpl(this._client);

  @override
  bool get hasApiKey => _client.hasApiKey;

  @override
  Future<String> sendMessage({
    required String userText,
    required String systemPrompt,
  }) {
    return _client.sendMessage(userText: userText, systemPrompt: systemPrompt);
  }

  @override
  void clearHistory() => _client.clearHistory();
}
