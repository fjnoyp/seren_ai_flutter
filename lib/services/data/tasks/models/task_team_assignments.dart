import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';

part 'task_team_assignments.g.dart';

@JsonSerializable()
class TaskTeamAssignments implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'task_id')
  final String taskId;

  @JsonKey(name: 'team_id')
  final String teamId;

  TaskTeamAssignments({
    required this.id,
    required this.taskId,
    required this.teamId,
  });

  factory TaskTeamAssignments.fromJson(Map<String, dynamic> json) => _$TaskTeamAssignmentsFromJson(json);
  Map<String, dynamic> toJson() => _$TaskTeamAssignmentsToJson(this);
}
