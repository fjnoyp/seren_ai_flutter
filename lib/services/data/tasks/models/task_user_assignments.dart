import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';

part 'task_user_assignments.g.dart';

@JsonSerializable()
class TaskUserAssignments implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'task_id')
  final String taskId;

  @JsonKey(name: 'user_id')
  final String userId;

  TaskUserAssignments({
    required this.id,
    required this.taskId,
    required this.userId,
  });

  factory TaskUserAssignments.fromJson(Map<String, dynamic> json) => _$TaskUserAssignmentsFromJson(json);
  Map<String, dynamic> toJson() => _$TaskUserAssignmentsToJson(this);
}
