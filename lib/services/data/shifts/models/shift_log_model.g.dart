// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftLogModel _$ShiftLogModelFromJson(Map<String, dynamic> json) =>
    ShiftLogModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      shiftId: json['shift_id'] as String,
      clockInDatetime: DateTime.parse(json['clock_in_datetime'] as String),
      clockOutDatetime: json['clock_out_datetime'] == null
          ? null
          : DateTime.parse(json['clock_out_datetime'] as String),
      isBreak: ShiftLogModel._boolFromInt(json['is_break']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ShiftLogModelToJson(ShiftLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'shift_id': instance.shiftId,
      'clock_in_datetime': instance.clockInDatetime.toIso8601String(),
      'clock_out_datetime': instance.clockOutDatetime?.toIso8601String(),
      'is_break': instance.isBreak,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
