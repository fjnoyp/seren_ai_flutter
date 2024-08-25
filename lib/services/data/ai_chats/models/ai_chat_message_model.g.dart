// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatMessageModel _$AiChatMessageModelFromJson(Map<String, dynamic> json) =>
    AiChatMessageModel(
      id: json['id'] as String?,
      type: $enumDecode(_$AiChatMessageTypeEnumMap, json['type']),
      createdAt: DateTime.parse(json['created_at'] as String),
      content: json['content'] as String,
      parentChatThreadId: json['parent_chat_thread_id'] as String,
    );

Map<String, dynamic> _$AiChatMessageModelToJson(AiChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AiChatMessageTypeEnumMap[instance.type]!,
      'created_at': instance.createdAt.toIso8601String(),
      'content': instance.content,
      'parent_chat_thread_id': instance.parentChatThreadId,
    };

const _$AiChatMessageTypeEnumMap = {
  AiChatMessageType.ai: 'ai',
  AiChatMessageType.user: 'user',
};
