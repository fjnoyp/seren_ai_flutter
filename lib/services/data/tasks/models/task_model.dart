import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'task_model.g.dart';

enum StatusEnum { cancelled, open, inProgress, finished, archived }
enum PriorityEnum { veryLow, low, normal, high, veryHigh }

@JsonSerializable()
class TaskModel implements IHasId{
  @override
  final String id;
  final String name;
  final String? description;  

  @JsonKey(name: 'status')
  final StatusEnum? status;

  @JsonKey(name: 'priority')
  final PriorityEnum? priority;

  @JsonKey(name: 'due_date')
  final DateTime? dueDate;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'author_user_id')
  final String authorUserId;

  @JsonKey(name: 'parent_team_id')
  final String? parentTeamId;

  @JsonKey(name: 'parent_project_id')
  final String parentProjectId;

  @JsonKey(name: 'estimated_duration_minutes')
  final int? estimatedDurationMinutes;

  TaskModel({    
    String? id,
    required this.name,
    required this.description,
    required this.status,
    this.priority,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
    required this.authorUserId,    
    this.parentTeamId,
    required this.parentProjectId,
    this.estimatedDurationMinutes,
  }) : id = id ?? uuid.v4();

  // Factory constructor for creating a TaskModel with default values
  factory TaskModel.defaultTask() {
    final now = DateTime.now().toUtc();
    return TaskModel(
      name: 'New Task',
      description: null,
      status: StatusEnum.open,
      priority: PriorityEnum.normal,
      dueDate: null,
      createdAt: now,
      updatedAt: now,
      authorUserId: '',  // This should be set to the current user's ID in practice
      parentTeamId: null,
      parentProjectId: '',  // This should be set to a valid project ID in practice
      estimatedDurationMinutes: null,
    );
  }

  TaskModel copyWith({
    String? id,
    String? name,
    String? description,
    StatusEnum? status,
    PriorityEnum? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorUserId,
    String? parentTeamId,
    String? parentProjectId,
    int? estimatedDurationMinutes,
  }) {
    return TaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorUserId: authorUserId ?? this.authorUserId,
      parentTeamId: parentTeamId ?? this.parentTeamId,
      parentProjectId: parentProjectId ?? this.parentProjectId,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}