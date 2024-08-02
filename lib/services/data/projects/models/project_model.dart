import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel implements IHasId {
  @override
  final String id;
  final String name;
  final String? description;

  @JsonKey(name: 'parent_org_id')
  final String parentOrgId;

  @JsonKey(name: 'parent_team_id')
  final String? parentTeamId;

  ProjectModel({
    String? id,
    required this.name,
    required this.description,
    required this.parentOrgId,
    required this.parentTeamId,    
  }) : id = id ?? uuid.v4();

  factory ProjectModel.fromJson(Map<String, dynamic> json) => _$ProjectModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);
}


