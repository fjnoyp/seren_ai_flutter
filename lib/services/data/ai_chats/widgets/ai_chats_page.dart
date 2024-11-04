import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/utils/string_extension.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/ai_request_executor.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_info_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_ui_action_request_model.dart';
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
            SelectableText(
                'Parent LG Assistant ID: ${thread.parentLgAssistantId}'),
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
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 2), // More pronounced border
        borderRadius: BorderRadius.circular(8), // Optional: rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  message.type.toString().enumToHumanReadable,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  icon: Icon(
                      isExpanded.value ? Icons.expand_less : Icons.expand_more),
                  label: Text(isExpanded.value ? 'Less' : 'More'),
                  onPressed: () => isExpanded.value = !isExpanded.value,
                ),
              ],
            ),
            const Divider(),
            Text(
              'Content:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (message.isAiRequest())
              DisplayToolResponse(
                  toolResponses: message.getAiRequests() ?? [])
            else
              DisplayContent(
                  content: message.content, isExpanded: isExpanded.value),
            const SizedBox(height: 8),
            if (isExpanded.value) ...[
              const SizedBox(height: 16),
              const SizedBox(height: 8),
              Text('ID: ${message.id}'),
              Text('Thread ID: ${message.parentChatThreadId}'),
              if (message.parentLgRunId != null)
                Text('LG Run ID: ${message.parentLgRunId}'),
            ],
          ],
        ),
      ),
    );
  }
}

class DisplayContent extends StatelessWidget {
  final String content;
  final bool isExpanded;

  const DisplayContent(
      {super.key, required this.content, this.isExpanded = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      isExpanded
          ? content
          : (content.length > 100
              ? '${content.substring(0, 100)}...'
              : content),
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

class DisplayToolResponse extends StatelessWidget {
  final List<AiRequestModel> toolResponses;

  const DisplayToolResponse({super.key, required this.toolResponses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...toolResponses.map((response) {
          final responseType = response.requestType.value;

          // Create a widget for each response with better formatting
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Response Type: $responseType',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (response is AiActionRequestModel) ...[
                  Text(
                      'Action Request Type: ${response.actionRequestType.value}'),
                  Text('Args: ${response.args}'),
                ] else if (response is AiUiActionRequestModel) ...[
                  Text('UI Action Type: ${response.uiActionType.value}'),
                  Text('Args: ${response.args}'),
                ] else if (response is AiInfoRequestModel) ...[
                  Text('Info Request Type: ${response.infoRequestType.value}'),
                  Text('Args: ${response.args}'),
                  Text('Show Only: ${response.showOnly}'),
                ],
                const SizedBox(height: 8), // Add space between responses
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
