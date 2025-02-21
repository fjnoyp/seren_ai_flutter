import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_ai_chat_message_role.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum AiChatMessageType { ai, user, tool }

extension AiChatMessageTypeExtension on AiChatMessageType {
  String toHumanReadable(BuildContext context) => switch (this) {
        AiChatMessageType.ai => AppLocalizations.of(context)!.ai,
        AiChatMessageType.user => AppLocalizations.of(context)!.user,
        AiChatMessageType.tool => AppLocalizations.of(context)!.tool,
      };

  static AiChatMessageType fromLgAiChatMessageRole(LgAiChatMessageRole role) {
    switch (role) {
      case LgAiChatMessageRole.ai:
        return AiChatMessageType.ai;
      case LgAiChatMessageRole.user:
        return AiChatMessageType.user;
      case LgAiChatMessageRole.tool:
        return AiChatMessageType.tool;
      // TODO p4: mapping system to ai message - since we should never receive system message from ai calls ...
      case LgAiChatMessageRole.system:
        return AiChatMessageType.ai;
    }
  }
}
