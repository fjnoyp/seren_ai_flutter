import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'task_reminder_model.g.dart';

@JsonSerializable()
class TaskReminderModel implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'task_id')
  final String taskId;

  @JsonKey(name: 'reminder_offset_minutes')
  final int reminderOffsetMinutes;

  @JsonKey(
    name: 'is_completed',
    fromJson: _boolFromInt,
  )
  final bool isCompleted;

  static bool _boolFromInt(value) => (value as num).toInt() == 1;

  TaskReminderModel({
    String? id,
    required this.taskId,
    required this.reminderOffsetMinutes,
    required this.isCompleted,
  }) : id = id ?? uuid.v4();

  factory TaskReminderModel.fromJson(Map<String, dynamic> json) =>
      _$TaskReminderModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskReminderModelToJson(this);
}
