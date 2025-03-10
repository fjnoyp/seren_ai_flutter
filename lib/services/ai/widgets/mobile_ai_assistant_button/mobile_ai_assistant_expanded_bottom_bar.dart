import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_assistant_expanded_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_listen_state_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_service_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_status_provider.dart';
import 'package:seren_ai_flutter/widgets/scaffold/bottom_app_bar_base.dart';

// This is shown in place of the bottom app bar on mobile when the ai modal is visible ...

// TODO p5: save and retrieve this preference locally
final textFieldVisibilityProvider = StateProvider<bool>((ref) => false);

/// Should be displayed when the isAiAssistantExpandedProvider is true
class MobileAiAssistantExpandedBottomBar extends ConsumerWidget {
  const MobileAiAssistantExpandedBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTextFieldVisible = ref.watch(textFieldVisibilityProvider);
    final speechState = ref.watch(speechToTextStatusProvider).speechState;
    final isPaused = speechState != SpeechToTextStateEnum.listening &&
        ref.watch(speechToTextListenStateProvider).text.isNotEmpty;

    // Get the height of the keyboard
    // final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return BottomAppBarBase(
      //height: isTextFieldVisible ? 200.0 : 65.0,
      height: 65.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top control row with simplified controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Cancel button
              Expanded(
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: const Icon(Icons.close, size: 22),
                  onPressed: () {
                    // First close the assistant UI immediately
                    ref.read(isAiAssistantExpandedProvider.notifier).state =
                        false;

                    // Then cancel listening (this can happen in the background)
                    Future.microtask(() {
                      ref
                          .read(speechToTextListenStateProvider.notifier)
                          .cancelListening();
                    });
                  },
                ),
              ),

              if (isPaused && !isTextFieldVisible)
                Expanded(
                  child: IconButton(
                    tooltip: 'Resume',
                    icon: const Icon(Icons.mic, size: 22),
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () {
                      ref
                          .read(speechToTextListenStateProvider.notifier)
                          .resumeListening();
                    },
                  ),
                )
              else
                Expanded(
                  child: IconButton(
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
                ),

              const Spacer(),
              const Spacer(),
              const Spacer(),

              // Right side - Done button (opens full chat)
              Expanded(
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: const Icon(Icons.open_in_new, size: 22),
                  onPressed: () {
                    // First close the assistant UI immediately
                    ref.read(isAiAssistantExpandedProvider.notifier).state =
                        false;

                    // Then navigate (this can happen in the background)
                    Future.microtask(() {
                      ref
                          .read(navigationServiceProvider)
                          .navigateTo(AppRoutes.aiChats.name);
                    });
                  },
                ),
              ),
            ],
          ),

          // AI responding progress indicator
          // Consumer(
          //   builder: (context, ref, child) {
          //     final isAiResponding = ref.watch(isAiRespondingProvider);
          //     return Visibility(
          //       visible: isAiResponding,
          //       child: LinearProgressIndicator(
          //         valueColor: AlwaysStoppedAnimation<Color>(
          //             Theme.of(context).colorScheme.primary),
          //       ),
          //     );
          //   },
          // ),

          // AI content areas
          // const AiResultsWidget(),
          // const SpeechTranscribedWidget(),

          // // Input controls based on mode
          // if (isTextFieldVisible) ...[
          //   UserInputTextDisplayWidget(),
          //   SizedBox(height: keyboardHeight), // Add space for the keyboard
          // ]
        ],
      ),
    );
  }
}
