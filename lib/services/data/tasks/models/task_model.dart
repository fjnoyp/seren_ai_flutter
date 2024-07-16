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

  @JsonKey(name: 'assigned_user_id')
  final String? assignedUserId;

  @JsonKey(name: 'parent_team_id')
  final String? parentTeamId;

  @JsonKey(name: 'parent_project_id')
  final String parentProjectId;

  @JsonKey(name: 'estimated_duration')
  final int? estimatedDuration;

  @JsonKey(name: 'list_durations')
  final List<Map<String, DateTime>>? listDurations;

  TaskModel({
    required this.id,
    required this.name,
    required this.description,
    required this.statusEnum,
    required this.priorityEnum,
    required this.dueDate,
    required this.createdDate,
    required this.lastUpdatedDate,
    required this.authorUserId,
    required this.assignedUserId,
    required this.parentTeamId,
    required this.parentProjectId,
    required this.estimatedDuration,
    required this.listDurations,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}