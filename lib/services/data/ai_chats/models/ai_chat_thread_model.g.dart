// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_thread_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatThreadModel _$AiChatThreadModelFromJson(Map<String, dynamic> json) =>
    AiChatThreadModel(
      id: json['id'] as String?,
      authorUserId: json['author_user_id'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      summary: json['summary'] as String?,
    );

Map<String, dynamic> _$AiChatThreadModelToJson(AiChatThreadModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author_user_id': instance.authorUserId,
      'name': instance.name,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'summary': instance.summary,
    };
