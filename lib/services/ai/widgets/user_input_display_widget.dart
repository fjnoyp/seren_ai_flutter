import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/ai/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_modal_visible_provider.dart';

import 'package:seren_ai_flutter/services/ai/widgets/ai_results_widget.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_state_control_button_widget.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_transcribed_widget.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_notifier.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_service.dart';
import 'package:seren_ai_flutter/widgets/scaffold/bottom_app_bar_base.dart';

// This is shown in place of the bottom app bar on mobile when the ai modal is visible ...

// TODO p5: save and retrieve this preference locally
final textFieldVisibilityProvider = StateProvider<bool>((ref) => false);

/// Class to display user's voice input or manual text input
/// Adapted to use the consistent BottomAppBarBase for styling
class UserInputDisplayWidget extends ConsumerWidget {
  const UserInputDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTextFieldVisible = ref.watch(textFieldVisibilityProvider);
    final textToSpeechService = ref.watch(textToSpeechServiceProvider.notifier);
    final textToSpeechState = ref.watch(textToSpeechServiceProvider);

    // Get the height of the keyboard
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return BottomAppBarBase(
      height: isTextFieldVisible ? 200.0 : 65.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top control row - we keep this consistent with the style of _QuickActionsBottomAppBar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side controls
              Row(
                children: [
                  // Input mode toggle
                  IconButton(
                    icon: Icon(
                      isTextFieldVisible ? Icons.mic : Icons.keyboard,
                      size: 22,
                    ),
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () {
                      ref.read(textFieldVisibilityProvider.notifier).state =
                          !isTextFieldVisible;
                    },
                  ),

                  // TTS toggle button (conditionally displayed)
                  if (textToSpeechState == TextToSpeechStateEnum.speaking)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      icon: const Icon(Icons.volume_off, size: 22),
                      onPressed: () => textToSpeechService.stop(),
                    ),
                ],
              ),

              // Right side controls
              Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: const Icon(Icons.open_in_new, size: 22),
                    onPressed: () {
                      ref.read(isAiModalVisibleProvider.notifier).state = false;
                      ref
                          .read(navigationServiceProvider)
                          .navigateTo(AppRoutes.aiChats.name);
                    },
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: const Icon(Icons.close, size: 22),
                    onPressed: () => ref
                        .read(isAiModalVisibleProvider.notifier)
                        .state = false,
                  ),
                ],
              ),
            ],
          ),

          // AI responding progress indicator
          Consumer(
            builder: (context, ref, child) {
              final isAiResponding = ref.watch(isAiRespondingProvider);
              return Visibility(
                visible: isAiResponding,
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary),
                ),
              );
            },
          ),

          // AI content areas
          const AiResultsWidget(),
          const SpeechTranscribedWidget(),

          // Input controls based on mode
          if (isTextFieldVisible) ...[
            UserInputTextDisplayWidget(),
            SizedBox(height: keyboardHeight), // Add space for the keyboard
          ] else
            const Stack(
              alignment: Alignment.center,
              children: [
                SpeechStateControlButtonWidget(),
              ],
            )
        ],
      ),
    );
  }
}

class UserInputTextDisplayWidget extends ConsumerWidget {
  final TextEditingController textEditingController = TextEditingController();

  UserInputTextDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textEditingController,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Enter something',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => textEditingController.clear(),
                ),
              ),
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              FocusScope.of(context).unfocus();

              await ref
                  .read(aiChatServiceProvider)
                  .sendMessageToAi(textEditingController.text);

              textEditingController.clear();
            },
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
