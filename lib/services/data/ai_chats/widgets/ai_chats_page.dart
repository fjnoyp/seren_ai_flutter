import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/utils/string_extension.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_info_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_ui_action_request_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/testing/ai_debug_page.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_user_ai_chat_messages_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_user_ai_chat_thread_provider.dart';
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
        title: const Text('Chat Thread'),
        trailing: IconButton(
          icon: Icon(isExpanded.value ? Icons.expand_less : Icons.expand_more),
          onPressed: () => isExpanded.value = !isExpanded.value,
        ),
        subtitle: AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              SelectableText('Thread ID: ${thread.id}'),
              SelectableText('Author: ${thread.authorUserId}'),
              SelectableText('Parent LG Thread ID: ${thread.parentLgThreadId}'),
              SelectableText(
                  'Parent LG Assistant ID: ${thread.parentLgAssistantId}'),
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
                  MessageCard(message: chatMessages[index]),
            ),
    );
  }
}

class MessageCard extends HookWidget {
  final AiChatMessageModel message;

  const MessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 2), // More pronounced border
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
            if (message.getAiRequest() case AiRequestModel toolResponse)
              DisplayToolResponse(toolResponse: toolResponse)
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
  final AiRequestModel toolResponse;

  const DisplayToolResponse({super.key, required this.toolResponse});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Get the response type from the toolResponse

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Response Type: ${toolResponse.requestType.value}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (toolResponse is AiActionRequestModel) ...[
                Text(
                    'Action Request Type: ${(toolResponse as AiActionRequestModel).actionRequestType.value}'),
                Text('Args: ${(toolResponse as AiActionRequestModel).args}'),
              ] else if (toolResponse is AiUiActionRequestModel) ...[
                Text(
                    'UI Action Type: ${(toolResponse as AiUiActionRequestModel).uiActionType.value}'),
                Text('Args: ${(toolResponse as AiUiActionRequestModel).args}'),
              ] else if (toolResponse is AiInfoRequestModel) ...[
                Text(
                    'Info Request Type: ${(toolResponse as AiInfoRequestModel).infoRequestType.value}'),
                Text('Args: ${(toolResponse as AiInfoRequestModel).args}'),
                Text(
                    'Show Only: ${(toolResponse as AiInfoRequestModel).showOnly}'),
              ],
              const SizedBox(height: 8), // Add space between responses
            ],
          ),
        ),
      ],
    );
  }
}
