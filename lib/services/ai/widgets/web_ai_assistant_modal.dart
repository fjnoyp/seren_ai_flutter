import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_assistant_expanded_provider.dart';
import 'package:seren_ai_flutter/services/ai/widgets/ai_chat_text_field.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/widgets/ai_chats_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WebAiAssistantView extends ConsumerWidget {
  const WebAiAssistantView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width: 12),
                  Hero(
                    tag: 'ai-chat-title',
                    child: Text(AppLocalizations.of(context)!.aiAssistant,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const Expanded(child: SizedBox.shrink()),
                  IconButton(
                    onPressed: () {
                      ref.read(isAiAssistantExpandedProvider.notifier).state =
                          false;
                      ref
                          .read(navigationServiceProvider)
                          .navigateTo(AppRoutes.aiChats.name);
                    },
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                    ),
                    icon: const Icon(Icons.open_in_new),
                  ),
                  IconButton(
                    onPressed: () {
                      // Confirm if we should clear the text field when closing the modal
                      // ref.read(aiChatTextEditingControllerProvider).clear();
                      ref.read(isAiAssistantExpandedProvider.notifier).state =
                          false;
                    },
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                    ),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Expanded(
                  child: Hero(
                tag: 'ai-chat-messages-display',
                child: ChatMessagesDisplay(),
              )),
              const AiChatTextField(),
            ],
          ),
        ),
      ),
    );
  }
}
