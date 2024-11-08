import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_chat_message_role.dart';

enum AiChatMessageType { ai, user, tool }

extension AiChatMessageTypeExtension on AiChatMessageType {
  static AiChatMessageType fromLgAiChatMessageRole(LgAiChatMessageRole role) {
    switch (role) {
      case LgAiChatMessageRole.ai:
        return AiChatMessageType.ai;
      case LgAiChatMessageRole.user:
        return AiChatMessageType.user;
      case LgAiChatMessageRole.tool:
        return AiChatMessageType.tool;
    }
  }
}
