// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_thread_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatThreadModel _$AiChatThreadModelFromJson(Map<String, dynamic> json) =>
    AiChatThreadModel(
      id: json['id'] as String?,
      authorUserId: json['author_user_id'] as String,
      parentLgThreadId: json['parent_lg_thread_id'] as String,
      parentOrgId: json['parent_org_id'] as String,
      parentLgAssistantId: json['parent_lg_assistant_id'] as String,
    );

Map<String, dynamic> _$AiChatThreadModelToJson(AiChatThreadModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author_user_id': instance.authorUserId,
      'parent_lg_thread_id': instance.parentLgThreadId,
      'parent_org_id': instance.parentOrgId,
      'parent_lg_assistant_id': instance.parentLgAssistantId,
    };
