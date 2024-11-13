import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_ui_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_type.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/messages/ai_tool_result_message_widget.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/messages/user_ai_chat_message_widget.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/messages/ui_action_message_widget.dart';

class AiChatMessageWidget extends StatelessWidget {
  final AiChatMessageModel message;
  final bool showToolMessages;

  const AiChatMessageWidget({
    super.key,
    required this.message,
    this.showToolMessages = true,
  });

  @override
  Widget build(BuildContext context) {
    return switch (message.type) {
      AiChatMessageType.user => UserAiChatMessageWidget(message: message),
      AiChatMessageType.ai => AiChatMessageWidget(message: message),
      AiChatMessageType.tool => showToolMessages
          ? _ToolMessageWidget(message: message)
          : const SizedBox.shrink(),
    };
  }
}

class _ToolMessageWidget extends StatelessWidget {
  final AiChatMessageModel message;

  const _ToolMessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    // A navigation card in case of UI Action Requests
    if (message.isUiActionRequest) {
      return UiActionMessageWidget(
        AiUiActionRequestModel.fromEncodedJson(message.content),
      );
    }
    // The respective widget in case of Request Results
    if (message.isAiResult) {
      return AiToolResultMessageWidget(
        AiRequestResultModel.fromEncodedJson(message.content),
      );
    }
    // Nothing in case of Tool Requests
    return const SizedBox.shrink();
  }
}
