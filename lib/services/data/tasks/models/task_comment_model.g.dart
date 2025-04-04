// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskCommentModel _$TaskCommentModelFromJson(Map<String, dynamic> json) =>
    TaskCommentModel(
      id: json['id'] as String?,
      authorUserId: json['author_user_id'] as String,
      parentTaskId: json['parent_task_id'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      content: json['content'] as String?,
      startDateTime: json['start_datetime'] == null
          ? null
          : DateTime.parse(json['start_datetime'] as String),
      endDateTime: json['end_datetime'] == null
          ? null
          : DateTime.parse(json['end_datetime'] as String),
    );

Map<String, dynamic> _$TaskCommentModelToJson(TaskCommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author_user_id': instance.authorUserId,
      'parent_task_id': instance.parentTaskId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'content': instance.content,
      'start_datetime': instance.startDateTime?.toIso8601String(),
      'end_datetime': instance.endDateTime?.toIso8601String(),
    };
