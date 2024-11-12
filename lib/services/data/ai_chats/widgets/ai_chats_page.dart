import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/testing/ai_debug_page.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_user_ai_chat_messages_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_user_ai_chat_thread_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/ai_chat_message_view_card.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';

class AIChatsPage extends HookConsumerWidget {
  const AIChatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final isDebugMode = useState(false);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          isDebugMode.value
              ? const AiDebugPage()
              : Column(
                  children: [
                    TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        labelText: 'Ask a question',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            final message = messageController.text;
                            if (message.isNotEmpty) {
                              ref
                                  .read(aiChatServiceProvider)
                                  .sendMessageToAi(message);
                              messageController.clear();
                            }
                          },
                        ),
                      ),
                    ),
                    const ChatThreadDisplay(),
                    const ChatMessagesDisplay(),
                    const SizedBox(height: 200),
                  ],
                ),
        ],
      ),
    );
  }
}

class ChatThreadDisplay extends ConsumerWidget {
  const ChatThreadDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueHandlerWidget(
      value: ref.watch(curUserAiChatThreadProvider),
      data: (chatThread) => chatThread == null
          ? const Text('No chat thread available')
          : ChatThreadCard(thread: chatThread),
    );
  }
}

class ChatThreadCard extends HookWidget {
  final AiChatThreadModel thread;

  const ChatThreadCard({super.key, required this.thread});

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);

    return Card(
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Chat Thread'),
            IconButton(
              icon: Icon(isExpanded.value ? Icons.expand_less : Icons.expand_more),
              onPressed: () => isExpanded.value = !isExpanded.value,
            ),
          ],
        ),
        subtitle: AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              _InfoRow('Thread ID', thread.id),
              _InfoRow('Author', thread.authorUserId),
              _InfoRow('Parent LG Thread ID', thread.parentLgThreadId),
              _InfoRow(
                  'Parent LG Assistant ID', thread.parentLgAssistantId),
            ],
          ),
          crossFadeState: isExpanded.value
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}

class ChatMessagesDisplay extends ConsumerWidget {
  const ChatMessagesDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatMessages = ref.watch(curUserAiChatMessagesProvider);
    return AsyncValueHandlerWidget(
      value: chatMessages,
      data: (chatMessages) => chatMessages.isEmpty
          ? const Text('No messages available')
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) =>
                  AiChatMessageViewCard(message: chatMessages[index]),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: SelectableText(
            value,
            maxLines: 1,
            //overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.copy, size: 15),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
          },
        ),
      ],
    );
  }
}
