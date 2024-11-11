import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/ai_interaction/last_ai_message_listener_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_request_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_type.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';
import 'dart:convert';

part 'ai_chat_message_model.g.dart';

@JsonSerializable()
class AiChatMessageModel extends AiResult implements IHasId {
  @override
  final String id;
  @JsonKey(name: 'type')
  final AiChatMessageType type;

  final String _content;
  @JsonKey(name: 'parent_chat_thread_id')
  final String parentChatThreadId;
  @JsonKey(name: 'parent_lg_run_id')
  final String? parentLgRunId;

  //@JsonKey(name: 'additional_kwargs', fromJson: _parseAdditionalKwargs)
  //final Map<String, dynamic>? additionalKwargs;

  AiChatMessageModel({
    String? id,
    required this.type,
    required String content,
    required this.parentChatThreadId,
    this.parentLgRunId,
    //this.additionalKwargs,
  })  : id = id ?? uuid.v4(),
        _content = content;

  String get content => switch (_content[0]) {
        '[' => jsonDecode(_content)[0]['text'] ?? _content,
        '{' => jsonDecode(_content)['text'] ?? _content,
        _ => _content,
      };

  // Factory constructor for creating a AiChatMessage with default values
  factory AiChatMessageModel.defaultMessage() {
    return AiChatMessageModel(
      type: AiChatMessageType.user, // Assuming default type as user
      content: 'New Message',
      parentChatThreadId:
          '', // This should be set to a valid chat thread ID in practice
    );
  }

  bool isAiToolRequest() {
    return type == AiChatMessageType.tool && content.contains('request_type');
  }

  AiRequestModel? getAiRequest() {
    if (isAiToolRequest()) {
      try {
        final Map<String, dynamic> decoded =
            json.decode(content) as Map<String, dynamic>;
        return AiRequestModel.fromJson(decoded);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // TODO isAiResult / getAiResults for the answer

  AiChatMessageModel copyWith({
    String? id,
    AiChatMessageType? type,
    String? content,
    String? parentChatThreadId,
    String? parentLgRunId,
    //Map<String, dynamic>? additionalKwargs,
  }) {
    return AiChatMessageModel(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      parentChatThreadId: parentChatThreadId ?? this.parentChatThreadId,
      parentLgRunId: parentLgRunId ?? this.parentLgRunId,
      //additionalKwargs: additionalKwargs ?? this.additionalKwargs,
    );
  }

  static List<AiChatMessageModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map(
            (json) => AiChatMessageModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  factory AiChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$AiChatMessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$AiChatMessageModelToJson(this);
}
