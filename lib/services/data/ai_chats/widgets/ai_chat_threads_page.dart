/// For seeing the users's chat threads 

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/ai_chat_threads_db_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/cur_user_ai_chat_threads_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/ai_chat_thread_messages_page.dart';

class AiChatThreadsPage extends ConsumerWidget {
  const AiChatThreadsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatThreads = ref.watch(curUserAiChatThreadsListenerProvider);

    return chatThreads == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: chatThreads.length,
                    itemBuilder: (context, index) {
                      return _buildChatThreadItem(context, chatThreads[index]);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => _createNewChatThread(context, ref),
                    child: const Text('Create New Chat Thread'),
                  ),
                ),
              ],
            );
  }

  Future<void> _createNewChatThread(BuildContext context, WidgetRef ref) async {
    final aiChatThreadsDb = ref.read(aiChatThreadsDbProvider);
    final curUser = ref.read(curAuthUserProvider);

    if(curUser == null) {
      throw Exception('Current user not found');
    }

    final newThread = AiChatThreadModel(      
      name: 'New Chat Thread',
      createdAt: DateTime.now().toUtc(),
      authorUserId: curUser.id,
    );

    await aiChatThreadsDb.insertItem(newThread);

    openAiChatMessages(context, newThread.id);

    /*
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New chat thread created')),
    );
    */
  }

  Widget _buildChatThreadItem(BuildContext context, AiChatThreadModel thread) {
    return ListTile(
      title: Text(thread.name),
      subtitle: Text(thread.summary ?? 'No summary available'),
      trailing: Text(
        '${thread.createdAt.day}/${thread.createdAt.month}/${thread.createdAt.year}',
      ),
      onTap: () {
        openAiChatMessages(context, thread.id);
      },
    );
  }
}
