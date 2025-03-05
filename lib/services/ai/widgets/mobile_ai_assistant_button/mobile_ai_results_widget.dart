import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/models/ai_chat_message_type.dart';
import 'package:seren_ai_flutter/services/ai/ai_is_responding_provider.dart';
import 'package:seren_ai_flutter/services/ai/last_ai_message_listener_provider.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/widgets/ai_chat_message_view_card.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_overlay_container.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_ai_assistant_overlay_manager.dart';

/// Displays the last messages from the AI in a scrollable overlay
class MobileAiResultsWidget extends HookConsumerWidget {
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
    final isVisible = useState(lastAiResults.isNotEmpty);

    // Filter out tool AI requests
    final filteredResults = lastAiResults
        .where((message) =>
            message.getDisplayType() != AiChatMessageDisplayType.toolAiRequest)
        .toList()
        .reversed
        .toList();

    // Handle visibility changes
    useEffect(() {
      if (lastAiResults.isEmpty) {
        isVisible.value = false;
      } else {
        isVisible.value = true;
      }
      return null;
    }, [lastAiResults]);

    // Don't render anything in the widget itself if not visible
    if (!isVisible.value || filteredResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main content
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
          ),
          // Loading overlay - shows when waiting for AI response
          Consumer(
            builder: (context, ref, child) {
              final isLoading = ref.watch(isAiRespondingProvider);
              if (!isLoading) return const SizedBox.shrink();
              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
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
              );
            },
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
                  // Hide the overlay
                  hide();
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
                        color: Colors.black.withOpacity(0.2),
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
