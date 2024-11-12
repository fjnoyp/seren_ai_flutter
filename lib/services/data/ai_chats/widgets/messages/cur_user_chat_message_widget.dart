import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/messages/collapsable_text.dart';

class CurUserChatMessageWidget extends StatelessWidget {
  const CurUserChatMessageWidget({
    super.key,
    required this.message,
  });

  final AiChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(left: 80.0, right: 16.0),
          child: Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CollapsableText(
                message.content,
                alignment: AlignmentDirectional.centerEnd,
              ),
            ),
          ),
        ),
      );
  }
}
