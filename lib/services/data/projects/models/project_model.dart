import 'package:json_annotation/json_annotation.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel {
  final String id;
  final String name;
  final String? description;

  @JsonKey(name: 'parent_team_id')
  final String parentTeamId;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.parentTeamId,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => _$ProjectModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);
}


