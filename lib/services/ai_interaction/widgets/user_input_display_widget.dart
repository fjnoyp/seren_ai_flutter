import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/is_ai_modal_visible_provider.dart';

import 'package:seren_ai_flutter/services/ai_interaction/widgets/ai_results_widget.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_state_control_button_widget.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_transcribed_widget.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_notifier.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_service.dart';

// TODO: save and retrieve this preference locally
final textFieldVisibilityProvider = StateProvider<bool>((ref) => false);

/// Class to display user's voice input or manual text input
class UserInputDisplayWidget extends ConsumerWidget {
  const UserInputDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTextFieldVisible = ref.watch(textFieldVisibilityProvider);
    final textToSpeechService = ref.watch(textToSpeechServiceProvider.notifier);
    final textToSpeechState = ref.watch(textToSpeechServiceProvider);

    // Get the height of the keyboard
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Row(
                children: [
                  isTextFieldVisible
                      ? IconButton(
                          icon: const Icon(Icons.mic),
                          onPressed: () {
                            ref
                                .read(textFieldVisibilityProvider.notifier)
                                .state = false;
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.keyboard),
                          onPressed: () {
                            ref
                                .read(textFieldVisibilityProvider.notifier)
                                .state = true;
                          },
                        ),
                  // TODO p4: maybe we should make this a persistent choice
                  if (textToSpeechState ==
                      TextToSpeechStateEnum.speaking)
                    IconButton(
                      onPressed: () => textToSpeechService.stop(),
                      icon: const Icon(Icons.volume_off),
                    ),

                  const Expanded(child: SizedBox.shrink()),

                  IconButton(
                    onPressed: () {
                      ref.read(isAiModalVisibleProvider.notifier).state = false;
                      ref.read(navigationServiceProvider).navigateTo(AppRoutes.aiChats.name);
                    },
                    icon: const Icon(Icons.open_in_new),
                  ),
                  IconButton(
                    onPressed: () => ref.read(isAiModalVisibleProvider.notifier).state = false,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
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
            const AiResultsWidget(),
            const SpeechTranscribedWidget(),
            if (isTextFieldVisible) ...[
              UserInputTextDisplayWidget(),
              SizedBox(height: keyboardHeight), // Add space for the keyboard
            ] else
              const Stack(
                alignment: Alignment.center,
                children: [
                  // Use padding to center the volume wave visualization with the speech control button's topView
                  // TODO: solve behavior issue with volume wave visualization before we use it again
                  // Padding(
                  //   padding: EdgeInsets.only(
                  //       bottom:
                  //           25), // 80 / 2 (container) - 30 / 2 (wave visualization)
                  //   child: ListenVolumeWidget(),
                  // ),
                  SpeechStateControlButtonWidget(),
                ],
              )
          ],
        ),
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
