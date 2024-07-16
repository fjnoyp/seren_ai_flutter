import 'package:json_annotation/json_annotation.dart';

part 'user_project_roles.g.dart';

@JsonSerializable()
class UserProjectRoles {
  final String id;
  final String userId;
  final String projectId;
  final String projectRole;

  UserProjectRoles({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.projectRole,
  });

  factory UserProjectRoles.fromJson(Map<String, dynamic> json) => _$UserProjectRolesFromJson(json);
  Map<String, dynamic> toJson() => _$UserProjectRolesToJson(this);
}
