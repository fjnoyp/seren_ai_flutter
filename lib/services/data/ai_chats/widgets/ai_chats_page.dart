import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_api_service_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/cur_user_ai_chat_thread_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/cur_user_chat_messages_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';

class AIChatsPage extends HookConsumerWidget {
  const AIChatsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();

    return ListView(
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
                  ref.read(aiChatServiceProvider).sendMessage(message);
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
    );
  }
}

class ChatThreadDisplay extends ConsumerWidget {
  const ChatThreadDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatThread = ref.watch(curUserAiChatThreadListenerProvider);
    return chatThread == null
        ? const Text('No chat thread available')
        : ChatThreadCard(thread: chatThread);
  }
}

class ChatThreadCard extends StatelessWidget {
  final AiChatThreadModel thread;

  const ChatThreadCard({Key? key, required this.thread}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: SelectableText('Chat Thread ID: ${thread.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText('Author: ${thread.authorUserId}'),
            SelectableText('Parent LG Thread ID: ${thread.parentLgThreadId}'),
          ],
        ),
      ),
    );
  }
}

class ChatMessagesDisplay extends ConsumerWidget {
  const ChatMessagesDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatMessages = ref.watch(curUserChatMessagesListenerProvider);
    return chatMessages == null
        ? const Text('No messages available')
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: chatMessages.length,
            itemBuilder: (context, index) =>
                MessageCard(message: chatMessages[index]),
          );
  }
}

class MessageCard extends HookWidget {
  final AiChatMessageModel message;

  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('Type: ${message.type}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  child: Text(isExpanded.value ? 'Collapse' : 'Expand'),
                  onPressed: () {
                    isExpanded.value = !isExpanded.value;
                  },
                ),
                Text(
                  isExpanded.value
                      ? message.content
                      : (message.content.length > 50
                          ? '${message.content.substring(0, 50)}...'
                          : message.content),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
