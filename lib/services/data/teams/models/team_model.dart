import 'package:json_annotation/json_annotation.dart';

part 'team_model.g.dart';

@JsonSerializable()
class TeamModel {
  final String id;
  final String name;

  @JsonKey(name: 'parent_org_id')
  final String parentOrgId;

  TeamModel({
    required this.id,
    required this.name,
    required this.parentOrgId,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) => _$TeamModelFromJson(json);
  Map<String, dynamic> toJson() => _$TeamModelToJson(this);
}
