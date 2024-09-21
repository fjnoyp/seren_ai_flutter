import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'note_folder_model.g.dart';

@JsonSerializable()
class NoteFolderModel implements IHasId {
  @override
  final String id;
  final String name;
  final String? description;

  @JsonKey(name: 'parent_team_id')
  final String? parentTeamId;

  @JsonKey(name: 'parent_project_id')
  final String parentProjectId;

  @JsonKey(name: 'estimated_duration_minutes')
  final int? estimatedDurationMinutes;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  NoteFolderModel({
    String? id,
    required this.name,
    this.description,
    this.parentTeamId,
    required this.parentProjectId,
    this.estimatedDurationMinutes,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  // Factory constructor for creating a NoteFolderModel with default values
  factory NoteFolderModel.defaultNoteFolder() {
    final now = DateTime.now().toUtc();
    return NoteFolderModel(
      name: 'New Note Folder',
      description: null,
      parentTeamId: null,
      parentProjectId: '',  // This should be set to a valid project ID in practice
      estimatedDurationMinutes: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  NoteFolderModel copyWith({
    String? id,
    String? name,
    String? description,
    String? parentTeamId,
    String? parentProjectId,
    int? estimatedDurationMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteFolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentTeamId: parentTeamId ?? this.parentTeamId,
      parentProjectId: parentProjectId ?? this.parentProjectId,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory NoteFolderModel.fromJson(Map<String, dynamic> json) => _$NoteFolderModelFromJson(json);
  Map<String, dynamic> toJson() => _$NoteFolderModelToJson(this);
}

