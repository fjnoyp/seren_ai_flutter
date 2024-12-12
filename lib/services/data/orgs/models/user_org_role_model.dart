import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'user_org_role_model.g.dart';

enum OrgRole {
  admin,
  editor,
  member;

  String toHumanReadable(BuildContext context) => switch (this) {
        OrgRole.admin => AppLocalizations.of(context)!.admin,
        OrgRole.editor => AppLocalizations.of(context)!.editor,
        OrgRole.member => AppLocalizations.of(context)!.member,
      };
}

@JsonSerializable()
class UserOrgRoleModel implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'org_id')
  final String orgId;

  @JsonKey(name: 'org_role')
  final OrgRole orgRole;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  UserOrgRoleModel({
    String? id,
    required this.userId,
    required this.orgId,
    required this.orgRole,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  factory UserOrgRoleModel.fromJson(Map<String, dynamic> json) => _$UserOrgRoleModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserOrgRoleModelToJson(this);

  UserOrgRoleModel copyWith({
    String? id,
    String? userId,
    String? orgId,
    OrgRole? orgRole,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserOrgRoleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orgId: orgId ?? this.orgId,
      orgRole: orgRole ?? this.orgRole,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
