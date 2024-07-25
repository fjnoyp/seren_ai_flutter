import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

enum StatusEnum { cancelled, open, inProgress, finished, archived }
enum PriorityEnum { veryLow, low, normal, high, veryHigh }

@JsonSerializable()
class TaskModel {
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
    required this.id,
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
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}