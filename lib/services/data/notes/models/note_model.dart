import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'note_model.g.dart';

@JsonSerializable()
class NoteModel implements IHasId {
  @override
  final String id;
  final String name;

  @JsonKey(name: 'author_user_id')
  final String authorUserId;

  final DateTime? date;
  final String? address;
  final String? description;

  @JsonKey(name: 'action_required')
  final String? actionRequired;
  final StatusEnum? status;

  @JsonKey(name: 'parent_project_id')
  final String? parentProjectId;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // This field is required but is not set by the client.
  // It's automatically assigned in the backend based on its project's org,
  // via Supabase function.
  // See: [https://github.com/fjnoyp/seren_ai_supabase/blob/main/migrations/20240706210333_create_parent_org_id_funcs.sql]
  final String? _parentOrgId;

  @JsonKey(name: 'parent_org_id')
  String? get parentOrgId => _parentOrgId;

  NoteModel({
    String? id,
    required this.name,
    required this.authorUserId,
    this.date,
    this.address,
    this.description,
    this.actionRequired,
    this.status,
    this.parentProjectId,
    this.createdAt,
    this.updatedAt,
    String? parentOrgId,
  })  : _parentOrgId = parentOrgId,
        id = id ?? uuid.v4();

  factory NoteModel.defaultNote() {
    final now = DateTime.now().toUtc();
    return NoteModel(
      name: 'New Note',
      authorUserId:
          '', // This should be set to the current user's ID in practice
      date: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  NoteModel copyWith({
    String? id,
    String? name,
    String? authorUserId,
    DateTime? date,
    String? address,
    String? description,
    String? actionRequired,
    StatusEnum? status,
    String? parentProjectId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool setAsPersonal = false,
  }) {
    return NoteModel(
      id: id ?? this.id,
      name: name ?? this.name,
      authorUserId: authorUserId ?? this.authorUserId,
      date: date ?? this.date,
      address: address ?? this.address,
      description: description ?? this.description,
      actionRequired: actionRequired ?? this.actionRequired,
      status: status ?? this.status,
      parentProjectId:
          setAsPersonal ? null : parentProjectId ?? this.parentProjectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      _$NoteModelFromJson(json);
  Map<String, dynamic> toJson() => _$NoteModelToJson(this);
}
