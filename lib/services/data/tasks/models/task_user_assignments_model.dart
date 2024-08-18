import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'task_user_assignments_model.g.dart';

@JsonSerializable()
class TaskUserAssignmentsModel implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'task_id')
  final String taskId;

  @JsonKey(name: 'user_id')
  final String userId;

  TaskUserAssignmentsModel({  
    String? id,
    required this.taskId,
    required this.userId,
  }) : id = id ?? uuid.v4();

  factory TaskUserAssignmentsModel.fromJson(Map<String, dynamic> json) => _$TaskUserAssignmentsModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskUserAssignmentsModelToJson(this);
}
