import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'user_team_assignment_model.g.dart';

@JsonSerializable()
class UserTeamAssignmentModel implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'team_id')
  final String teamId;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  UserTeamAssignmentModel({
    String? id,
    required this.userId,
    required this.teamId,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  factory UserTeamAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$UserTeamAssignmentModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserTeamAssignmentModelToJson(this);

  UserTeamAssignmentModel copyWith({
    String? id,
    String? userId,
    String? teamId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserTeamAssignmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      teamId: teamId ?? this.teamId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
