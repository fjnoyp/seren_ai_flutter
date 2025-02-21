import 'dart:convert';

import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_ai_chat_message_role.dart';

/// The base message model returned by the Langgraph API
class LgAiBaseMessageModel {
  final String content;
  final LgAiChatMessageRole type;
  final String id;
  final Map<String, dynamic> _additionalFields;

  LgAiBaseMessageModel({
    required dynamic messageContent,
    required dynamic messageType,
    required String id,
    Map<String, dynamic>? additionalFields,
  })  : content = (messageContent is List)
            ? json.encode(messageContent)
            : messageContent.toString(),
        type = (messageType == "ai")
            ? LgAiChatMessageRole.ai
            : LgAiChatMessageRole.tool,
        id = id,
        _additionalFields = additionalFields ?? {};

  factory LgAiBaseMessageModel.fromJson(Map<String, dynamic> json) {
    final additionalFields = Map<String, dynamic>.from(json);
    additionalFields
        .removeWhere((key, value) => ['content', 'type', 'id'].contains(key));

    return LgAiBaseMessageModel(
      messageContent: json['content'],
      messageType: json['type'],
      id: json['id'],
      additionalFields: additionalFields,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'type': type.name,
      'id': id,
      ..._additionalFields,
    };
  }

  @override
  String toString() {
    return 'LgAiBaseMessageModel(content: $content, type: $type, id: $id)';
  }

  LgAiBaseMessageModel copyWithContent(String newContent) {
    return LgAiBaseMessageModel(
      messageContent: newContent,
      messageType: type.name,
      id: id,
      additionalFields: _additionalFields,
    );
  }
}
