import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'task_user_assignment_model.g.dart';

@JsonSerializable()
class TaskUserAssignmentModel implements IHasId {
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

  TaskUserAssignmentModel({
    String? id,
    required this.taskId,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  factory TaskUserAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$TaskUserAssignmentModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskUserAssignmentModelToJson(this);

  TaskUserAssignmentModel copyWith({
    String? id,
    String? taskId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskUserAssignmentModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
