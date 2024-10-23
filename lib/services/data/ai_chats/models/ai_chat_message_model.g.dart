// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatMessageModel _$AiChatMessageModelFromJson(Map<String, dynamic> json) =>
    AiChatMessageModel(
      id: json['id'] as String?,
      type: $enumDecode(_$AiChatMessageTypeEnumMap, json['type']),
      content: json['content'] as String,
      parentChatThreadId: json['parent_chat_thread_id'] as String,
      parentLgRunId: json['parent_lg_run_id'] as String?,
      additionalKwargs:
          AiChatMessageModel._parseAdditionalKwargs(json['additional_kwargs']),
    );

Map<String, dynamic> _$AiChatMessageModelToJson(AiChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AiChatMessageTypeEnumMap[instance.type]!,
      'content': instance.content,
      'parent_chat_thread_id': instance.parentChatThreadId,
      'parent_lg_run_id': instance.parentLgRunId,
      'additional_kwargs': instance.additionalKwargs,
    };

const _$AiChatMessageTypeEnumMap = {
  AiChatMessageType.ai: 'ai',
  AiChatMessageType.user: 'user',
  AiChatMessageType.tool: 'tool',
};
