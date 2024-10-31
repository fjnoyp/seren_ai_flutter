import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'team_project_assignment_model.g.dart';

@JsonSerializable()
class TeamProjectAssignmentModel {
  final String id;
  final String teamId;
  final String projectId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  TeamProjectAssignmentModel({
    String? id,
    required this.teamId,
    required this.projectId,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  factory TeamProjectAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$TeamProjectAssignmentModelFromJson(json);
  Map<String, dynamic> toJson() => _$TeamProjectAssignmentModelToJson(this);

  TeamProjectAssignmentModel copyWith({
    String? id,
    String? teamId,
    String? projectId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeamProjectAssignmentModel(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
