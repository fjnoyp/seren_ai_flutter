import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_modal_visibility_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/ai_chats_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WebAIAssistantModal extends ConsumerWidget {
  const WebAIAssistantModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
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
                  Text(AppLocalizations.of(context)!.aiAssistant,
                      style: Theme.of(context).textTheme.titleMedium),
                  const Expanded(child: SizedBox.shrink()),
                  IconButton(
                    onPressed: () {
                      ref.read(aiModalVisibilityProvider.notifier).state =
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
                    onPressed: () => ref
                        .read(aiModalVisibilityProvider.notifier)
                        .state = false,
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                    ),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Expanded(child: PaginatedChatMessagesDisplay()),
              const AIChatTextField(),
            ],
          ),
        ),
      ),
    );
  }
}
