/// For seeing the users's chat threads

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: 'Ask a question',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      final message = messageController.text;
                      if (message.isNotEmpty) {
                        ref.read(aiChatApiServiceProvider).sendMessage(message);
                        messageController.clear();
                      }
                    },
                  ),
                ),
              ),
              _buildChatThreadDisplay(ref),
            ],
          ),
        ),
        _buildChatMessagesDisplay(ref),
        const SliverToBoxAdapter(
          child: SizedBox(height: 200),
        ),
      ],
    );
  }

  Widget _buildChatThreadDisplay(WidgetRef ref) {
    final chatThread = ref.watch(curUserAiChatThreadListenerProvider);
    return chatThread == null
        ? const Text('No chat thread available')
        : _buildChatThreadCard(chatThread);
  }

  Widget _buildChatThreadCard(AiChatThreadModel thread) {
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

  Widget _buildChatMessagesDisplay(WidgetRef ref) {
    final chatMessages = ref.watch(curUserChatMessagesListenerProvider);
    return chatMessages == null
        ? const SliverToBoxAdapter(child: Text('No messages available'))
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildMessageCard(chatMessages[index]),
              childCount: chatMessages.length,
            ),
          );
  }

  Widget _buildMessageCard(AiChatMessageModel message) {
    return MessageCard(message: message);
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
