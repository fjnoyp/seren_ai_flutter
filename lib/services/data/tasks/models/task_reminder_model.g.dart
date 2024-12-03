// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_reminder_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskReminderModel _$TaskReminderModelFromJson(Map<String, dynamic> json) =>
    TaskReminderModel(
      id: json['id'] as String?,
      taskId: json['task_id'] as String,
      reminderOffsetMinutes: (json['reminder_offset_minutes'] as num).toInt(),
      isCompleted: TaskReminderModel._boolFromInt(json['is_completed']),
    );

Map<String, dynamic> _$TaskReminderModelToJson(TaskReminderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'reminder_offset_minutes': instance.reminderOffsetMinutes,
      'is_completed': instance.isCompleted,
    };
