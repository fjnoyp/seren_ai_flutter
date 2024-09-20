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
      timezone: json['timezone'] as String,
    );

Map<String, dynamic> _$ShiftTimeframeModelToJson(
        ShiftTimeframeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shift_id': instance.shiftId,
      'day_of_week': instance.dayOfWeek,
      'start_time': instance.startTime,
      'duration': durationToString(instance.duration),
      'timezone': instance.timezone,
    };
