// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteModel _$NoteModelFromJson(Map<String, dynamic> json) => NoteModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      authorUserId: json['author_user_id'] as String,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      address: json['address'] as String?,
      description: json['description'] as String?,
      actionRequired: json['action_required'] as String?,
      status: json['status'] as String?,
      parentNoteFolderId: json['parent_note_folder_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$NoteModelToJson(NoteModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'author_user_id': instance.authorUserId,
      'date': instance.date?.toIso8601String(),
      'address': instance.address,
      'description': instance.description,
      'action_required': instance.actionRequired,
      'status': instance.status,
      'parent_note_folder_id': instance.parentNoteFolderId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
