/// For seeing the messages in a chat thread
///
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/cur_user_ai_chat_messages_listener_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/cur_user_ai_chat_threads_listener_provider.dart';

class AiChatThreadMessagesPage extends ConsumerWidget {
  final String threadId;

  const AiChatThreadMessagesPage({Key? key, required this.threadId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScrollController scrollController = ScrollController();

    final threads = ref.watch(curUserAiChatThreadsListenerProvider);
    final curThread = threads?.firstWhere((thread) => thread.id == threadId);
    final messages = ref.watch(curUserAiChatMessagesListenerFamProvider(threadId));

    if (curThread == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Scroll to the top of the list whenever the state updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Column(
      children: [
        _displayParentChatThread(curThread),
        Expanded(
          child: messages == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageItem(context, messages[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _displayParentChatThread(AiChatThreadModel curThread) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thread ID: ${curThread.id}'),
            Text('Author User ID: ${curThread.authorUserId}'),
            Text('Name: ${curThread.name}'),
            Text('Created At: ${curThread.createdAt}'),
            if (curThread.summary != null) Text('Summary: ${curThread.summary}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, AiChatMessageModel message) {
    return ListTile(
      title: Text(
        message.type == AiChatMessageType.ai ? 'AI' : 'User',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: message.type == AiChatMessageType.ai ? Colors.blue : Colors.green,
        ),
      ),
      subtitle: Text(message.content),
      trailing: Text(
        '${message.createdAt.hour}:${message.createdAt.minute}',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

Future<void> openAiChatMessages(BuildContext context, String threadId) async {
  await Navigator.pushNamed(context, aiChatThreadMessagesRoute,
      arguments: {'threadId': threadId});
}