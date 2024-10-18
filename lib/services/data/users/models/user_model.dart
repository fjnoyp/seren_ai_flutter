import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'parent_auth_user_id')
  final String parentAuthUserId; 
  final String email;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'default_project_id')
  final String? defaultProjectId;

  @JsonKey(name: 'default_team_id')
  final String? defaultTeamId;

  UserModel({
    String? id,
    required this.parentAuthUserId,
    required this.email,
    this.createdAt,
    this.defaultProjectId,
    this.defaultTeamId,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? parentAuthUserId,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      parentAuthUserId: parentAuthUserId ?? this.parentAuthUserId,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}