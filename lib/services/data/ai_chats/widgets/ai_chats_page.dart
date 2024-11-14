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
import 'package:seren_ai_flutter/widgets/common/debug_mode_provider.dart';

class AIChatsPage extends HookConsumerWidget {
  const AIChatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final isDebugMode = ref.watch(isDebugModeSNP);

    return isDebugMode
        ? const AiDebugPage()
        : Expanded(
            child: Column(
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
                const Expanded(
                  child: ChatMessagesDisplay(),
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

  Widget _buildInfoRow(String label, String value) {
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
              icon: Icon(
                  isExpanded.value ? Icons.expand_less : Icons.expand_more),
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
              _buildInfoRow('Thread ID', thread.id),
              _buildInfoRow('Author', thread.authorUserId),
              _buildInfoRow('Parent LG Thread ID', thread.parentLgThreadId),
              _buildInfoRow(
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

class ChatMessagesDisplay extends HookConsumerWidget {
  const ChatMessagesDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final messagesProviderValue = ref.watch(curUserAiChatMessagesProvider);

    useEffect(() {
      void onScroll() {
        final providerData = messagesProviderValue.valueOrNull;
        if (providerData == null) return;

        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.8) {
          providerData.notifier.loadMore();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController, messagesProviderValue]);

    return messagesProviderValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (providerData) {
        final messages = providerData.state;
        return messages.isEmpty
            ? const Center(child: Text('No messages available'))
            : ListView.builder(
                controller: scrollController,
                itemCount:
                    messages.length + (providerData.notifier.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length &&
                      providerData.notifier.hasMore) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final message = messages[index];
                  return KeyedSubtree(
                    key: ValueKey(message.id),
                    child: AiChatMessageViewCard(message: message),
                  );
                },
              );
      },
    );
  }
}
