import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'ai_chat_thread_model.g.dart';

@JsonSerializable()
class AiChatThreadModel implements IHasId{
  @override
  final String id;
  @JsonKey(name: 'author_user_id')
  final String authorUserId;
  final String name;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  final String? summary;

  @JsonKey(name: 'parent_org_id')
  final String parentOrgId;

  AiChatThreadModel({
    String? id,
    required this.authorUserId,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.summary,
    required this.parentOrgId,
  }) : id = id ?? uuid.v4();

  AiChatThreadModel copyWith({
    String? id,
    String? authorUserId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? summary,
    String? parentOrgId,
  }) {
    return AiChatThreadModel(
      id: id ?? this.id,
      authorUserId: authorUserId ?? this.authorUserId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      summary: summary ?? this.summary,
      parentOrgId: parentOrgId ?? this.parentOrgId,
    );
  }

  factory AiChatThreadModel.fromJson(Map<String, dynamic> json) => _$AiChatThreadModelFromJson(json);
  Map<String, dynamic> toJson() => _$AiChatThreadModelToJson(this);
}
