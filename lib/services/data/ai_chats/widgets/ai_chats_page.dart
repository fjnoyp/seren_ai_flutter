import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/testing/ai_debug_page.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/chat_thread_display.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/chat_messages_display.dart';

class AIChatsPage extends HookConsumerWidget {
  const AIChatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final isDebugMode = useState(false);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(
                isDebugMode.value ? Icons.list : Icons.bug_report,
                size: 20,
              ),
              onPressed: () {
                isDebugMode.value = !isDebugMode.value;
              },
            ),
          ],
        ),
        if (isDebugMode.value)
          const AiDebugPage()
        else ...[
          const AiChatThreadDisplay(),
          const Expanded(child: AiChatMessagesDisplay()),
          TextField(
            controller: messageController,
            decoration: InputDecoration(
              labelText: 'Ask a question',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final message = messageController.text;
                  if (message.isNotEmpty) {
                    ref.read(aiChatServiceProvider).sendMessageToAi(message);
                    messageController.clear();
                  }
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
