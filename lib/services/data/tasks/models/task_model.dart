import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'task_model.g.dart';

enum PriorityEnum {
  veryLow,
  low,
  normal,
  high,
  veryHigh;

  String toHumanReadable(BuildContext context) => switch (this) {
        PriorityEnum.veryLow => AppLocalizations.of(context)!.veryLow,
        PriorityEnum.low => AppLocalizations.of(context)!.low,
        PriorityEnum.normal => AppLocalizations.of(context)!.normal,
        PriorityEnum.high => AppLocalizations.of(context)!.high,
        PriorityEnum.veryHigh => AppLocalizations.of(context)!.veryHigh,
      };
}

@JsonSerializable()
class TaskModel implements IHasId {
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

  @JsonKey(name: 'parent_project_id')
  final String parentProjectId;

  @JsonKey(
    name: 'estimated_duration_minutes',
    fromJson: _durationFromJson,
    toJson: _durationToJson
  )
  final int? estimatedDurationMinutes;

  static int? _durationFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static dynamic _durationToJson(int? value) => value;

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
      authorUserId:
          '', // This should be set to the current user's ID in practice
      parentProjectId:
          '', // This should be set to a valid project ID in practice
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
      parentProjectId: parentProjectId ?? this.parentProjectId,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}
