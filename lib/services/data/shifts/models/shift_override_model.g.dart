// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_override_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftOverrideModel _$ShiftOverrideModelFromJson(Map<String, dynamic> json) =>
    ShiftOverrideModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      shiftId: json['shift_id'] as String,
      startDateTime: DateTime.parse(json['start_datetime'] as String),
      endDateTime: DateTime.parse(json['end_datetime'] as String),
      isRemoval: json['is_removal'] == null
          ? false
          : boolFromInt((json['is_removal'] as num).toInt()),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ShiftOverrideModelToJson(ShiftOverrideModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'shift_id': instance.shiftId,
      'start_datetime': instance.startDateTime.toIso8601String(),
      'end_datetime': instance.endDateTime.toIso8601String(),
      'is_removal': boolToInt(instance.isRemoval),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
