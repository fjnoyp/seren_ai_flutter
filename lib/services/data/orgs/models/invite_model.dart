import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';

part 'invite_model.g.dart';

enum InviteStatus {
  pending,
  accepted,
  declined,
}

@JsonSerializable()
class InviteModel implements IHasId {
  @override
  final String id;

  final String email;

  @JsonKey(name: 'org_id')
  final String orgId;

  @JsonKey(name: 'org_role')
  final OrgRole orgRole;

  @JsonKey(name: 'author_user_id')
  final String authorUserId;

  final InviteStatus status;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  InviteModel({
    String? id,
    required this.email,
    required this.orgId,
    required this.orgRole,
    required this.authorUserId,
    this.status = InviteStatus.pending,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InviteModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory InviteModel.fromJson(Map<String, dynamic> json) =>
      _$InviteModelFromJson(json);
  Map<String, dynamic> toJson() => _$InviteModelToJson(this);

  InviteModel copyWith({
    String? id,
    String? email,
    String? orgId,
    OrgRole? orgRole,
    String? authorUserId,
    InviteStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InviteModel(
      id: id ?? this.id,
      email: email ?? this.email,
      orgId: orgId ?? this.orgId,
      orgRole: orgRole ?? this.orgRole,
      authorUserId: authorUserId ?? this.authorUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
