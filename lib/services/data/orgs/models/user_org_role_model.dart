import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';

part 'user_org_role_model.g.dart';

@JsonSerializable()
class UserOrgRoleModel implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'org_id')
  final String orgId;

  // TODO: switch to enum
  @JsonKey(name: 'org_role')
  final String orgRole;

  UserOrgRoleModel({
    required this.id,
    required this.userId,
    required this.orgId,
    required this.orgRole,
  });

  factory UserOrgRoleModel.fromJson(Map<String, dynamic> json) => _$UserOrgRoleModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserOrgRoleModelToJson(this);
}
