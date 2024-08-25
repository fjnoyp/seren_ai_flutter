import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'ai_chat_message_model.g.dart';

enum AiChatMessageType { ai, user }

@JsonSerializable()
class AiChatMessageModel implements IHasId{
  @override
  final String id;
  @JsonKey(name: 'type')
  final AiChatMessageType type;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final String content;
  @JsonKey(name: 'parent_chat_thread_id')
  final String parentChatThreadId;

  AiChatMessageModel({
    String? id,
    required this.type,
    required this.createdAt,
    required this.content,
    required this.parentChatThreadId,
  }) : id = id ?? uuid.v4();

  // Factory constructor for creating a AiChatMessage with default values
  factory AiChatMessageModel.defaultMessage() {
    final now = DateTime.now().toUtc();
    return AiChatMessageModel(
      type: AiChatMessageType.user, // Assuming default type as user
      createdAt: now,
      content: 'New Message',
      parentChatThreadId: '',  // This should be set to a valid chat thread ID in practice
    );
  }

  AiChatMessageModel copyWith({
    String? id,
    AiChatMessageType? type,
    DateTime? createdAt,
    String? content,
    String? parentChatThreadId,
  }) {
    return AiChatMessageModel(
      id: id ?? this.id,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      parentChatThreadId: parentChatThreadId ?? this.parentChatThreadId,
    );
  }

  factory AiChatMessageModel.fromJson(Map<String, dynamic> json) => _$AiChatMessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$AiChatMessageModelToJson(this);
}
