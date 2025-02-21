import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'ai_chat_thread_model.g.dart';

@JsonSerializable()
class AiChatThreadModel implements IHasId {
  @override
  final String id;
  @JsonKey(name: 'author_user_id')
  final String authorUserId;
  @JsonKey(name: 'parent_lg_thread_id')
  final String parentLgThreadId;
  @JsonKey(name: 'parent_org_id')
  final String parentOrgId;
  @JsonKey(name: 'parent_lg_assistant_id') 
  final String parentLgAssistantId;

  AiChatThreadModel({
    String? id,
    required this.authorUserId,
    required this.parentLgThreadId,
    required this.parentOrgId,
    required this.parentLgAssistantId,
  }) : id = id ?? uuid.v4();

  AiChatThreadModel copyWith({
    String? id,
    String? authorUserId,
    String? parentLgThreadId,
    String? parentOrgId,
    String? parentLgAssistantId,
  }) {
    return AiChatThreadModel(
      id: id ?? this.id,
      authorUserId: authorUserId ?? this.authorUserId,
      parentLgThreadId: parentLgThreadId ?? this.parentLgThreadId,
      parentOrgId: parentOrgId ?? this.parentOrgId,
      parentLgAssistantId: parentLgAssistantId ?? this.parentLgAssistantId,
    );
  }

  factory AiChatThreadModel.fromJson(Map<String, dynamic> json) => _$AiChatThreadModelFromJson(json);
  Map<String, dynamic> toJson() => _$AiChatThreadModelToJson(this);
}
