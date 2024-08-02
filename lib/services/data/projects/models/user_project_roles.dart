import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'user_project_roles.g.dart';

@JsonSerializable()
class UserProjectRoles {
  final String id;
  final String userId;
  final String projectId;
  final String projectRole;

  UserProjectRoles({
    String? id,
    required this.userId,
    required this.projectId,
    required this.projectRole,
  }) : id = id ?? uuid.v4();

  factory UserProjectRoles.fromJson(Map<String, dynamic> json) => _$UserProjectRolesFromJson(json);
  Map<String, dynamic> toJson() => _$UserProjectRolesToJson(this);
}
