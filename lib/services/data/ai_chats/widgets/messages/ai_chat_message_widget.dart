import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/messages/collapsable_text.dart';

class AiChatMessageWidget extends StatelessWidget {
  const AiChatMessageWidget({
    super.key,
    required this.message,
  });

  final AiChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    return message.content.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: CollapsableText(message.content),
          );
  }
}
