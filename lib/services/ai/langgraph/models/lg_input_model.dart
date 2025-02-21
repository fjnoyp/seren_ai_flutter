import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_ai_chat_message_role.dart';

/// Input model for the Langgraph API
class LgAgentStateModel {
  final List<LgInputMessageModel> messages;
  final String? uiContext;
  final AiBehaviorMode aiBehaviorMode;
  LgAgentStateModel(
      {required this.messages,
      this.uiContext,
      this.aiBehaviorMode = AiBehaviorMode.chat});

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((message) => message.toJson()).toList(),
      'ui_context': uiContext ?? '',
      'ai_behavior_mode': aiBehaviorMode.name,
    };
  }
}

enum AiBehaviorMode {
  chat,
  singleCall; // send as single_call

  String get name {
    switch (this) {
      case AiBehaviorMode.singleCall:
        return 'single_call';
      case AiBehaviorMode.chat:
        return 'chat';
    }
  }
}

/// Message model of the Input model for the Langgraph API
class LgInputMessageModel {
  final LgAiChatMessageRole role;
  final String content;
  final AiBehaviorMode aiBehaviorMode;

  LgInputMessageModel(
      {required this.role,
      required this.content,
      this.aiBehaviorMode = AiBehaviorMode.chat});

  factory LgInputMessageModel.fromJson(Map<String, dynamic> json) {
    return LgInputMessageModel(
      role: LgAiChatMessageRole.values.firstWhere(
          (e) => e.toString() == 'AiChatMessageType.${json['role']}'),
      content: json['content'],
      aiBehaviorMode: AiBehaviorMode.values.firstWhere(
          (e) => e.toString() == 'AiBehaviorMode.${json['aiBehaviorMode']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role.toString().split('.').last,
      'content': content,
      'aiBehaviorMode': aiBehaviorMode.name,
    };
  }
}
