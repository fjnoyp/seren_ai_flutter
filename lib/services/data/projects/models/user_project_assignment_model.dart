import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'user_project_assignment_model.g.dart';

@JsonSerializable()
class UserProjectAssignmentModel implements IHasId {
  @override
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'project_id')
  final String projectId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  UserProjectAssignmentModel({
    String? id,
    required this.userId,
    required this.projectId,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  factory UserProjectAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$UserProjectAssignmentModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserProjectAssignmentModelToJson(this);

  UserProjectAssignmentModel copyWith({
    String? id,
    String? userId,
    String? projectId,
    String? projectRole,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProjectAssignmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
