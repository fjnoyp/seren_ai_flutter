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

  @JsonKey(name: 'status_enum')
  final StatusEnum? statusEnum;

  @JsonKey(name: 'priority_enum')
  final PriorityEnum? priorityEnum;

  @JsonKey(name: 'due_date')
  final DateTime? dueDate;

  @JsonKey(name: 'created_date')
  final DateTime createdDate;

  @JsonKey(name: 'last_updated_date')
  final DateTime lastUpdatedDate;

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
    required this.statusEnum,
    this.priorityEnum,
    this.dueDate,
    required this.createdDate,
    required this.lastUpdatedDate,
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
      statusEnum: StatusEnum.open,
      priorityEnum: null,
      dueDate: null,
      createdDate: now,
      lastUpdatedDate: now,
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
    StatusEnum? statusEnum,
    PriorityEnum? priorityEnum,
    DateTime? dueDate,
    DateTime? createdDate,
    DateTime? lastUpdatedDate,
    String? authorUserId,
    String? parentTeamId,
    String? parentProjectId,
    int? estimatedDurationMinutes,
  }) {
    return TaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      statusEnum: statusEnum ?? this.statusEnum,
      priorityEnum: priorityEnum ?? this.priorityEnum,
      dueDate: dueDate ?? this.dueDate,
      createdDate: createdDate ?? this.createdDate,
      lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
      authorUserId: authorUserId ?? this.authorUserId,
      parentTeamId: parentTeamId ?? this.parentTeamId,
      parentProjectId: parentProjectId ?? this.parentProjectId,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}