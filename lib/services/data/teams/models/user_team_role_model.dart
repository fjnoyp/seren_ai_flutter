import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'user_team_role_model.g.dart';

@JsonSerializable()
class UserTeamRoleModel implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'team_id')
  final String teamId;

  @JsonKey(name: 'team_role')
  final String teamRole;

  UserTeamRoleModel({
    String? id,
    required this.userId,
    required this.teamId,
    required this.teamRole,
  }) : id = id ?? uuid.v4();

  factory UserTeamRoleModel.fromJson(Map<String, dynamic> json) => _$UserTeamRoleModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserTeamRoleModelToJson(this);
}
