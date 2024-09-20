import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'user_project_roles.g.dart';

@JsonSerializable()
class UserProjectRoles {
  final String id;
  final String userId;
  final String projectId;
  final String projectRole;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  UserProjectRoles({
    String? id,
    required this.userId,
    required this.projectId,
    required this.projectRole,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  factory UserProjectRoles.fromJson(Map<String, dynamic> json) => _$UserProjectRolesFromJson(json);
  Map<String, dynamic> toJson() => _$UserProjectRolesToJson(this);

  UserProjectRoles copyWith({
    String? id,
    String? userId,
    String? projectId,
    String? projectRole,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProjectRoles(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      projectRole: projectRole ?? this.projectRole,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
