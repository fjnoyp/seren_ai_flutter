import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'team_model.g.dart';

@JsonSerializable()
class TeamModel implements IHasId {
  @override
  final String id;
  final String name;

  @JsonKey(name: 'parent_org_id')
  final String parentOrgId;

  TeamModel({
    String? id,
    required this.name,
    required this.parentOrgId,
  }) : id = id ?? uuid.v4();

  factory TeamModel.fromJson(Map<String, dynamic> json) => _$TeamModelFromJson(json);
  Map<String, dynamic> toJson() => _$TeamModelToJson(this);
}
