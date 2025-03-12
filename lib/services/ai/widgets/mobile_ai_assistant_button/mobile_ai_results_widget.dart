import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_responding_provider.dart';
import 'package:seren_ai_flutter/services/ai/last_ai_message_listener_provider.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/widgets/ai_chat_message_view_card.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_overlay_container.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_ai_assistant_overlay_manager.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_notifier.dart';

/// Displays the last messages from the AI in a scrollable overlay
class MobileAiResultsWidget extends ConsumerWidget {
  const MobileAiResultsWidget({super.key});

  /// Show this widget as an overlay
  static void show(BuildContext context, GlobalKey anchorKey) {
    MobileAiAssistantOverlayManager.show(
      context: context,
      type: AiAssistantOverlayType.results,
      anchorKey: anchorKey,
      builder: (context) => const MobileAiResultsWidget(),
    );
  }

  /// Hide this overlay
  static void hide() {
    MobileAiAssistantOverlayManager.hide(AiAssistantOverlayType.results);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lastAiResults = ref.watch(lastAiMessageListenerProvider);
    final isAiResponding = ref.watch(isAiRespondingProvider);

    // Filter out tool AI requests
    final filteredResults = lastAiResults
        .where((message) =>
            message.getDisplayType() != AiChatMessageDisplayType.toolAiRequest)
        .toList()
        .reversed
        .toList();

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main content
          if (filteredResults.isNotEmpty)
            MobileOverlayContainer(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final message in filteredResults)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AiChatMessageViewCard(message: message),
                      ),
                  ],
                ),
              ),
            )
          // Loading overlay - shows when waiting for AI response
          else
            !isAiResponding
                ? const SizedBox.shrink()
                : Container(
                    width: 300,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(128),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'AI is thinking...',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

          // Close button in top right corner
          Positioned(
            top: -12,
            right: -12,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {
                  debugPrint("Close button tapped");
                  // Clear the messages to prevent auto-reshowing
                  ref.read(lastAiMessageListenerProvider.notifier).clearState();

                  // Stop AI talking
                  ref.read(textToSpeechServiceProvider.notifier).stop();

                  // Reset the AI responding state
                  ref.read(isAiRespondingProvider.notifier).state = false;
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
