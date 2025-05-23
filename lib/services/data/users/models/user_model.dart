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

  @JsonKey(name: 'first_name')
  final String firstName;

  @JsonKey(name: 'last_name')
  final String lastName;

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
    required this.firstName,
    required this.lastName,
    this.createdAt,
    this.defaultProjectId,
    this.defaultTeamId,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  // Override equality operator and hashCode to compare UserModel instances by ID only.
  // This ensures that two UserModel objects with the same ID are considered equal,
  // even if other fields like email, firstName, lastName, createdAt, or updatedAt differ.
  // This is important for operations like list.contains() to work correctly when checking
  // for the presence of a user in a list based solely on their unique identifier.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? parentAuthUserId,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? defaultProjectId,
    String? defaultTeamId,
  }) {
    return UserModel(
      id: id ?? this.id,
      parentAuthUserId: parentAuthUserId ?? this.parentAuthUserId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      defaultProjectId: defaultProjectId ?? this.defaultProjectId,
      defaultTeamId: defaultTeamId ?? this.defaultTeamId,
    );
  }
}
