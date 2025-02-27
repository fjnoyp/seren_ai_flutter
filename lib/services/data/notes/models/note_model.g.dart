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
      status: $enumDecodeNullable(_$StatusEnumEnumMap, json['status']),
      parentProjectId: json['parent_project_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      parentOrgId: json['parent_org_id'] as String?,
    );

Map<String, dynamic> _$NoteModelToJson(NoteModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'author_user_id': instance.authorUserId,
      'date': instance.date?.toIso8601String(),
      'address': instance.address,
      'description': instance.description,
      'action_required': instance.actionRequired,
      'status': _$StatusEnumEnumMap[instance.status],
      'parent_project_id': instance.parentProjectId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'parent_org_id': instance.parentOrgId,
    };

const _$StatusEnumEnumMap = {
  StatusEnum.cancelled: 'cancelled',
  StatusEnum.open: 'open',
  StatusEnum.inProgress: 'inProgress',
  StatusEnum.finished: 'finished',
  StatusEnum.archived: 'archived',
};
