import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_request_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/models/ai_chat_message_type.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'ai_chat_message_model.g.dart';

enum AiChatMessageDisplayType {
  user,
  ai,
  aiWithToolCall,
  tool,
  toolAiRequest,
  toolAiResult;

  String toHumanReadable(BuildContext context) => switch (this) {
        AiChatMessageDisplayType.user => AppLocalizations.of(context)!.user,
        AiChatMessageDisplayType.ai => AppLocalizations.of(context)!.ai,
        AiChatMessageDisplayType.aiWithToolCall =>
          AppLocalizations.of(context)!.aiWithToolCall,
        AiChatMessageDisplayType.tool => AppLocalizations.of(context)!.tool,
        AiChatMessageDisplayType.toolAiRequest =>
          AppLocalizations.of(context)!.toolAiRequest,
        AiChatMessageDisplayType.toolAiResult =>
          AppLocalizations.of(context)!.toolAiResult,
      };
}

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

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  //@JsonKey(name: 'additional_kwargs', fromJson: _parseAdditionalKwargs)
  //final Map<String, dynamic>? additionalKwargs;

  AiChatMessageModel({
    String? id,
    required this.type,
    required this.content,
    required this.parentChatThreadId,
    this.parentLgRunId,
    this.createdAt,
    //this.additionalKwargs,
  }) : id = id ?? uuid.v4();

  // Factory constructor for creating a AiChatMessage with default values
  factory AiChatMessageModel.defaultMessage() {
    return AiChatMessageModel(
      type: AiChatMessageType.user, // Assuming default type as user
      content: 'New Message',
      parentChatThreadId:
          '', // This should be set to a valid chat thread ID in practice
    );
  }

  AiChatMessageDisplayType getDisplayType() {
    switch (type) {
      case AiChatMessageType.user:
        return AiChatMessageDisplayType.user;
      case AiChatMessageType.ai:
        // If content is json list with tool_use, then it is a tool call
        if (content.startsWith('[') &&
            content.endsWith(']') &&
            content.contains('tool_use')) {
          return AiChatMessageDisplayType.aiWithToolCall;
        }

        return AiChatMessageDisplayType.ai;
      case AiChatMessageType.tool:

        // If content contains "request_type" then it is a request
        if (content.contains('request_type')) {
          return AiChatMessageDisplayType.toolAiRequest;
        }

        // If content contains "result_type" then it is a result
        if (content.contains('result_type')) {
          return AiChatMessageDisplayType.toolAiResult;
        }

        return AiChatMessageDisplayType.tool;
    }
  }

  bool isAiRequest() {
    return getDisplayType() == AiChatMessageDisplayType.toolAiRequest;
  }

  AiRequestModel? getAiRequest() {
    if (isAiRequest()) {
      final Map<String, dynamic> decoded =
          json.decode(content) as Map<String, dynamic>;
      return AiRequestModel.fromJson(decoded);
    }
    return null;
  }

  AiRequestResultModel? getAiResult() {
    if (getDisplayType() == AiChatMessageDisplayType.toolAiResult) {
      final Map<String, dynamic> decoded =
          json.decode(content) as Map<String, dynamic>;
      return AiRequestResultModel.fromJson(decoded);
    }
    return null;
  }

  String? getAiMessage() {
    if (getDisplayType() == AiChatMessageDisplayType.aiWithToolCall) {
      try {
        // Old Sonnet 3.5 Response Format (doesn't work for Groq, which doesn't have these fields in content at all)
        final List<dynamic> decoded = json.decode(content) as List<dynamic>;
        // Look for the first object with type "text" and return its text field
        for (final item in decoded) {
          final Map<String, dynamic> messageItem = item as Map<String, dynamic>;
          if (messageItem['type'] == 'text') {
            return messageItem['text'] as String;
          }
        }
      } catch (e) {
        // If content is not JSON or doesn't match expected format,
        // return the raw content
        return content;
      }
    } else if (getDisplayType() == AiChatMessageDisplayType.ai) {
      return content;
    }
    return null;
  }

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
