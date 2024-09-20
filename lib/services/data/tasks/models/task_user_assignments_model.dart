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

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  TaskUserAssignmentsModel({
    String? id,
    required this.taskId,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  factory TaskUserAssignmentsModel.fromJson(Map<String, dynamic> json) => _$TaskUserAssignmentsModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskUserAssignmentsModelToJson(this);

  TaskUserAssignmentsModel copyWith({
    String? id,
    String? taskId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskUserAssignmentsModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
