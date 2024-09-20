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

  AiChatThreadModel({
    String? id,
    required this.authorUserId,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.summary,
  }) : id = id ?? uuid.v4();

  // Factory constructor for creating a AiChatThreadModel with default values
  factory AiChatThreadModel.defaultThread() {
    final now = DateTime.now().toUtc();
    return AiChatThreadModel(
      authorUserId: '',  // This should be set to the current user's ID in practice
      name: 'New Thread',
      createdAt: now,
      summary: null,
    );
  }

  AiChatThreadModel copyWith({
    String? id,
    String? authorUserId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? summary,
  }) {
    return AiChatThreadModel(
      id: id ?? this.id,
      authorUserId: authorUserId ?? this.authorUserId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      summary: summary ?? this.summary,
    );
  }

  factory AiChatThreadModel.fromJson(Map<String, dynamic> json) => _$AiChatThreadModelFromJson(json);
  Map<String, dynamic> toJson() => _$AiChatThreadModelToJson(this);
}
