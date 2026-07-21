class AiMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final DateTime createdAt;

  AiMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  AiMessage copyWith({
    String? text,
    bool? isUser,
    bool? isError,
  }) {
    return AiMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isError: isError ?? this.isError,
      createdAt: createdAt,
    );
  }

  Map<String, String> toMap() => {
        'text': text,
        'isUser': isUser.toString(),
        'isError': isError.toString(),
      };

  factory AiMessage.fromMap(Map<String, String> m) => AiMessage(
        text: m['text'] ?? '',
        isUser: m['isUser'] == 'true',
        isError: m['isError'] == 'true',
      );
}
