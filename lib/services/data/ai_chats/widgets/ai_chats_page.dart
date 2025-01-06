import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/ai_chat_text_field.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/testing/ai_debug_page.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_user_ai_chat_messages_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_user_ai_chat_thread_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/ai_chat_message_view_card.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/ai_is_responding_indicator.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/widgets/common/debug_mode_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AIChatsPage extends HookConsumerWidget {
  const AIChatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDebugMode = ref.watch(isDebugModeSNP);
    final showDebugTest = useState(false);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWebVersion) ...[
            const SizedBox(width: 24),
            Hero(
              tag: 'ai-chat-title',
              child: Text(
                AppLocalizations.of(context)!.aiAssistant,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(width: 24),
          ],
          if (isDebugMode)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  showDebugTest.value ? Icons.list : Icons.bug_report,
                  size: 20,
                ),
                onPressed: () {
                  showDebugTest.value = !showDebugTest.value;
                },
              ),
            ),
          Expanded(
            child: showDebugTest.value
                ? const AiDebugPage()
                : const Column(
                    children: [
                      ChatThreadDisplay(),
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: AiChatTextField(),
                      ),
                    ],
                  ),
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
    return Expanded(
      child: AsyncValueHandlerWidget(
        value: ref.watch(curUserAiChatThreadProvider),
        data: (chatThread) => chatThread == null
            ? Center(
                child:
                    Text(AppLocalizations.of(context)!.noChatThreadAvailable))
            : Column(children: [
                ChatThreadCard(thread: chatThread),
                const Expanded(
                    child: Hero(
                  tag: 'ai-chat-messages-display',
                  child: PaginatedChatMessagesDisplay(),
                )),
              ]),
      ),
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
            Text(AppLocalizations.of(context)!.chatThread),
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
              _buildInfoRow(AppLocalizations.of(context)!.threadId, thread.id),
              _buildInfoRow(
                  AppLocalizations.of(context)!.author, thread.authorUserId),
              _buildInfoRow(AppLocalizations.of(context)!.parentLgThreadId,
                  thread.parentLgThreadId),
              _buildInfoRow(AppLocalizations.of(context)!.parentLgAssistantId,
                  thread.parentLgAssistantId),
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
    final chatMessages = ref.watch(curUserAiChatMessagesProvider);
    return AsyncValueHandlerWidget(
      value: chatMessages,
      data: (chatMessages) => chatMessages.isEmpty
          ? Text(AppLocalizations.of(context)!.noMessagesAvailable)
          : ListView.builder(
              reverse: true,
              shrinkWrap: true,
              itemCount: chatMessages.length,
              itemBuilder: (context, index) =>
                  AiChatMessageViewCard(message: chatMessages[index]),
            ),
      error: (error, stack) => Center(
          child: Text(AppLocalizations.of(context)!.noMessagesAvailable)),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class PaginatedChatMessagesDisplay extends HookConsumerWidget {
  const PaginatedChatMessagesDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final messagesProviderValue =
        ref.watch(curUserPaginatedAiChatMessagesProvider);

    useEffect(() {
      void onScroll() {
        final providerData = messagesProviderValue.valueOrNull;
        if (providerData == null) return;

        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.8) {
          providerData.notifier.loadMore();
        }

        if (scrollController.position.pixels == 0) {
          messagesProviderValue.valueOrNull?.notifier.hasNewMessages = false;
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController, messagesProviderValue]);

    return messagesProviderValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
          child: Text(AppLocalizations.of(context)!.error(error.toString()))),
      data: (providerData) {
        final messages = providerData.state;
        final isAiResponding = ref.watch(isAiRespondingProvider);

        return messages.isEmpty
            ? Text(AppLocalizations.of(context)!.noMessagesAvailable)
            : Stack(
                children: [
                  ListView.builder(
                    reverse: true,
                    controller: scrollController,
                    itemCount: messages.length +
                        (providerData.notifier.hasMore ? 1 : 0) +
                        (isAiResponding ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length &&
                          providerData.notifier.hasMore) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (index == 0 && isAiResponding) {
                        return const AiIsRespondingIndicator();
                      }
                      final message =
                          messages[isAiResponding ? index - 1 : index];
                      return KeyedSubtree(
                        key: ValueKey(message.id),
                        child: AiChatMessageViewCard(message: message),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: scrollController,
                    builder: (context, child) {
                      return scrollController.hasClients &&
                              scrollController.position.pixels > 100
                          ? Positioned(
                              bottom: 20,
                              right: 20,
                              child: messagesProviderValue.valueOrNull?.notifier
                                          .hasNewMessages ??
                                      false
                                  ? Badge(smallSize: 12, child: child)
                                  : child!,
                            )
                          : const SizedBox.shrink();
                    },
                    child: IconButton.filled(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () => scrollController.jumpTo(0),
                    ),
                  ),
                ],
              );
      },
    );
  }
}
