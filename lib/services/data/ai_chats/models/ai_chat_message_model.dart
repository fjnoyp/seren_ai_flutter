import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';
import 'dart:convert';

part 'ai_chat_message_model.g.dart';

enum AiChatMessageType { ai, user, tool }

@JsonSerializable()
class AiChatMessageModel implements IHasId {
  @override
  final String id;
  @JsonKey(name: 'type')
  final AiChatMessageType type;

  final String content;
  @JsonKey(name: 'parent_chat_thread_id')
  final String parentChatThreadId;
  @JsonKey(name: 'parent_lg_run_id')
  final String? parentLgRunId;

  @JsonKey(name: 'additional_kwargs', fromJson: _parseAdditionalKwargs)
  final Map<String, dynamic>? additionalKwargs;

  AiChatMessageModel({
    String? id,
    required this.type,
    required this.content,
    required this.parentChatThreadId,
    this.parentLgRunId,
    this.additionalKwargs,
  }) : id = id ?? uuid.v4();

  // Factory constructor for creating a AiChatMessage with default values
  factory AiChatMessageModel.defaultMessage() {
    return AiChatMessageModel(
      type: AiChatMessageType.user, // Assuming default type as user      
      content: 'New Message',
      parentChatThreadId: '',  // This should be set to a valid chat thread ID in practice
    );
  }

  AiChatMessageModel copyWith({
    String? id,
    AiChatMessageType? type,
    String? content,
    String? parentChatThreadId,
    String? parentLgRunId,
    Map<String, dynamic>? additionalKwargs,
  }) {
    return AiChatMessageModel(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      parentChatThreadId: parentChatThreadId ?? this.parentChatThreadId,
      parentLgRunId: parentLgRunId ?? this.parentLgRunId,
      additionalKwargs: additionalKwargs ?? this.additionalKwargs,
    );
  }

  static List<AiChatMessageModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AiChatMessageModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  factory AiChatMessageModel.fromJson(Map<String, dynamic> json) => _$AiChatMessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$AiChatMessageModelToJson(this);

  static Map<String, dynamic>? _parseAdditionalKwargs(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    } else if (value is String) {
      try {
        return jsonDecode(value) as Map<String, dynamic>;
      } catch (e) {
        print('Error parsing additional_kwargs: $e');
        return null;
      }
    }
    return null;
  }
}
