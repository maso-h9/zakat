// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiMessage _$AiMessageFromJson(Map<String, dynamic> json) => AiMessage(
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      isError: json['isError'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AiMessageToJson(AiMessage instance) => <String, dynamic>{
      'text': instance.text,
      'isUser': instance.isUser,
      'isError': instance.isError,
      'createdAt': instance.createdAt.toIso8601String(),
    };
