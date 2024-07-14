import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';

part 'team_model.g.dart';

@JsonSerializable()
class TeamModel implements IHasId {
  @override
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
