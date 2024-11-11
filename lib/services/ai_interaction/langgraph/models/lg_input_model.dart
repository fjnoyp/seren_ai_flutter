import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_chat_message_role.dart';

/// Input model for the Langgraph API
class LgAgentStateModel {
  final List<LgInputMessageModel> messages;

  LgAgentStateModel({required this.messages});

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}

/// Message model of the Input model for the Langgraph API
class LgInputMessageModel {
  final LgAiChatMessageRole role;
  final String content;

  LgInputMessageModel({required this.role, required this.content});

  factory LgInputMessageModel.fromJson(Map<String, dynamic> json) {
    return LgInputMessageModel(
      role: LgAiChatMessageRole.values.firstWhere(
          (e) => e.toString() == 'AiChatMessageType.${json['role']}'),
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role.toString().split('.').last,
      'content': content,
    };
  }
}

