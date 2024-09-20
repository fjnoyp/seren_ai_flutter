// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_timeframe_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftTimeframeModel _$ShiftTimeframeModelFromJson(Map<String, dynamic> json) =>
    ShiftTimeframeModel(
      id: json['id'] as String?,
      shiftId: json['shift_id'] as String,
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      startTime: json['start_time'] as String,
      duration: parseDuration(json['duration'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ShiftTimeframeModelToJson(
        ShiftTimeframeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shift_id': instance.shiftId,
      'day_of_week': instance.dayOfWeek,
      'start_time': instance.startTime,
      'duration': durationToString(instance.duration),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
