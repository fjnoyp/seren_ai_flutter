// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftModel _$ShiftModelFromJson(Map<String, dynamic> json) => ShiftModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      authorUserId: json['author_user_id'] as String,
      parentTeamId: json['parent_team_id'] as String?,
      parentProjectId: json['parent_project_id'] as String,
    );

Map<String, dynamic> _$ShiftModelToJson(ShiftModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'author_user_id': instance.authorUserId,
      'parent_team_id': instance.parentTeamId,
      'parent_project_id': instance.parentProjectId,
    };
