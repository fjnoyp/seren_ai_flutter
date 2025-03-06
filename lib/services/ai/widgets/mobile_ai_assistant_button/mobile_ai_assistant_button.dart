// A button that has suggestions on the side ...
// When clicked it puts the bottom ai bar into a different state ... user
// can then choose to use the ai or not ...
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_responding_provider.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_assistant_expanded_provider.dart';
import 'package:seren_ai_flutter/services/ai/last_ai_message_listener_provider.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_ai_assistant_expanded_bottom_bar.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_ai_results_widget.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_user_input_text_display_widget.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_listen_state_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_service_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_status_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_transcribed_widget.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_notifier.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_ai_assistant_overlay_manager.dart';

class MobileAiAssistantButton extends HookConsumerWidget {
  const MobileAiAssistantButton({
    super.key,
  });

  final double size = 56.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechState = ref.watch(speechToTextStatusProvider);
    final isListening =
        speechState.speechState == SpeechToTextStateEnum.listening;
    final isTextFieldVisible = ref.watch(textFieldVisibilityProvider);
    final isPaused = ref.watch(speechToTextListenStateProvider).text.isNotEmpty;

    // Watch for AI processing state
    final isAiResponding = ref.watch(isAiRespondingProvider);

    // Create a shared text controller
    final textController = useState(TextEditingController());

    // Create a GlobalKey for positioning overlays
    final buttonKey = useState(GlobalKey());

    // Watch for AI results and show them when available
    final lastAiResults = ref.watch(lastAiMessageListenerProvider);

    // Listen for text field visibility changes and show/hide overlay accordingly
    ref.listen<bool>(textFieldVisibilityProvider, (previous, current) {
      if (current &&
          !MobileAiAssistantOverlayManager.isShowing(
              AiAssistantOverlayType.textInput)) {
        // Show text field overlay
        MobileUserInputTextDisplayWidget.show(
          context,
          buttonKey.value,
          textController.value,
          () async {
            if (textController.value.text.isEmpty) return;

            // Show loading indicator
            ref.read(isAiRespondingProvider.notifier).state = true;

            // Send the text
            await ref
                .read(aiChatServiceProvider)
                .sendMessageToAi(textController.value.text);

            // Clear the text and hide the text field
            textController.value.clear();
            ref.read(textFieldVisibilityProvider.notifier).state = false;

            // Reset sending state
            ref.read(isAiRespondingProvider.notifier).state = false;
          },
        );
      } else if (!current &&
          MobileAiAssistantOverlayManager.isShowing(
              AiAssistantOverlayType.textInput)) {
        // Hide text field overlay
        MobileUserInputTextDisplayWidget.hide();
      }
    });

    // Handle showing/hiding overlays based on state
    useEffect(() {
      // Handle speech transcription visibility
      if ((isListening || isPaused) &&
          !MobileAiAssistantOverlayManager.isShowing(
              AiAssistantOverlayType.transcription)) {
        SpeechTranscribedWidget.show(context, buttonKey.value);
      } else if (!isListening &&
          !isPaused &&
          MobileAiAssistantOverlayManager.isShowing(
              AiAssistantOverlayType.transcription)) {
        SpeechTranscribedWidget.hide();
      }

      // Handle AI results visibility - but don't force show if already hidden
      // This allows user dismissal to stick
      if (lastAiResults.isNotEmpty &&
          !MobileAiAssistantOverlayManager.isShowing(
              AiAssistantOverlayType.results)) {
        MobileAiResultsWidget.show(context, buttonKey.value);
      } else if (lastAiResults.isEmpty &&
          MobileAiAssistantOverlayManager.isShowing(
              AiAssistantOverlayType.results)) {
        MobileAiResultsWidget.hide();
      }

      // Clean up overlays when unmounted
      return () {
        MobileAiAssistantOverlayManager.hideAll();
      };
    }, [isListening, isPaused, lastAiResults.length]);

    return Tooltip(
      message: AppLocalizations.of(context)!.aiAssistant,
      child: SizedBox(
        width: size * 1.5, // Large enough for the animation
        height: size * 1.5, // Add space for the text label at bottom
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Text input field (only visible when textFieldVisibility is true)
            // if (isTextFieldVisible)
            //   Positioned(
            //     bottom: size + 55, // Position it above the button
            //     child: MobileUserInputTextDisplayWidget(
            //       key: UniqueKey(),
            //       controller: textController.value,
            //     ),
            //   ),

            // Speech State widget - fixed position relative to the parent, not the button
            Positioned(
              bottom: -15, // Fixed position from the top of the Stack
              //left: 0,
              //right: 0,
              child: Container(
                alignment: Alignment.center, // Center the text horizontally
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isTextFieldVisible || isPaused
                      ? "Click to send"
                      : _mapSpeechStateToText(speechState.speechState),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // Positioned(
            //   bottom: size + 55,
            //   child: const MobileAiResultsWidget(),
            // ),

            // Positioned(
            //   bottom: size + 55,
            //   child: const SpeechTranscribedWidget(),
            // ),

            // const AiResultsWidget(),
            // const SpeechTranscribedWidget(),

            // Listening animation (only visible when listening)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animation layer (behind the button)
                    AnimatedOpacity(
                      opacity: (isListening && !isAiResponding) ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: _ListeningAnimation(size: size),
                    ),

                    // Button layer (on top of animation)
                    InkWell(
                      key: buttonKey
                          .value, // This is critical for the overlay positioning
                      onTap: () async {
                        if (isTextFieldVisible) {
                          if (textController.value.text.isEmpty) return;

                          // Show loading indicator
                          ref.read(isAiRespondingProvider.notifier).state =
                              true;

                          // Send the text
                          await ref
                              .read(aiChatServiceProvider)
                              .sendMessageToAi(textController.value.text);

                          // Clear the text and hide the text field
                          textController.value.clear();
                          ref.read(textFieldVisibilityProvider.notifier).state =
                              false;

                          // Reset sending state
                          ref.read(isAiRespondingProvider.notifier).state =
                              false;
                          return;
                        }

                        // Check if already listening
                        if (isListening || isPaused) {
                          // Show loading indicator
                          ref.read(isAiRespondingProvider.notifier).state =
                              true;

                          // Stop listening and send the transcript
                          Future.microtask(() async {
                            await ref
                                .read(speechToTextListenStateProvider.notifier)
                                .sendText(ref);
                            // Reset sending state after a short delay to ensure the UI updates properly
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              if (context.mounted) {
                                ref
                                    .read(isAiRespondingProvider.notifier)
                                    .state = false;
                              }
                            });
                          });
                        } else {
                          // First set the AI assistant to expanded immediately for a smooth UI transition
                          ref
                              .read(isAiAssistantExpandedProvider.notifier)
                              .state = true;

                          // Stop any ongoing text-to-speech
                          await ref
                              .read(textToSpeechServiceProvider.notifier)
                              .stop();

                          // Remove previous AI results
                          ref
                              .read(lastAiMessageListenerProvider.notifier)
                              .clearState();

                          // Start listening
                          final notifier = ref
                              .read(speechToTextListenStateProvider.notifier);
                          notifier.startListening();
                        }
                      },
                      child: SizedBox(
                        height: size,
                        width: size,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(51),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isAiResponding
                              ? _PulsatingLoadingIndicator()
                              : isTextFieldVisible || isPaused
                                  ? const Center(
                                      child: Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    )
                                  : isListening
                                      ? Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                              height: size * 0.8,
                                              width: size * 0.8,
                                            ),
                                            const Icon(
                                              Icons.mic,
                                              size: 24,
                                              color: Colors.white,
                                            ),
                                          ],
                                        )
                                      : SvgPicture.asset(
                                          'assets/images/AI button.svg',
                                          fit: BoxFit.scaleDown,
                                        ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mapSpeechStateToText(SpeechToTextStateEnum speechState) {
    switch (speechState) {
      case SpeechToTextStateEnum.startListening:
        return "Starting listen...";
      case SpeechToTextStateEnum.listening:
        return "Listening. Click to send.";
      case SpeechToTextStateEnum.startNotListening:
        return "Stopping listen....";
      case SpeechToTextStateEnum.notListening:
        return "Click to talk with AI.";
      case SpeechToTextStateEnum.done:
        return "Click to talk with AI.";
      case SpeechToTextStateEnum.available:
        return "Click to talk with AI.";
    }
  }
}

class _ListeningAnimation extends HookConsumerWidget {
  const _ListeningAnimation({required this.size});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textState = ref.watch(speechToTextListenStateProvider);

    // Use animation controller for rotation
    final animationController = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    // Start the animation when the controller is created
    useEffect(() {
      animationController.repeat();
      return null;
    }, const []);

    // Map sound level to animation speed and color intensity
    final intensity = 0.5 + (textState.soundLevel.abs() / 100.0) * 0.5;
    animationController.value = intensity; // Adjust speed based on sound level

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Container(
          width: size * 1.5, // Fixed size
          height: size * 1.5, // Fixed size
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                theme.colorScheme.primary.withAlpha(25),
                theme.colorScheme.primary.withAlpha((intensity * 255).toInt()),
                theme.colorScheme.primary.withAlpha(25),
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: GradientRotation(animationController.value * 6.28),
            ),
            border: Border.all(
              color: Colors.transparent,
              width: 3,
            ),
          ),
        );
      },
    );
  }
}

/// A pulsating loading indicator for the AI assistant button
class _PulsatingLoadingIndicator extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    // Create a repeating animation
    useEffect(() {
      animationController.repeat(reverse: true);
      // Don't return the dispose function - Flutter Hooks handles it automatically
      return null;
    }, const []);

    // Create a scaling animation
    final scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Create an opacity animation for the inner glow
    final opacityAnimation = Tween<double>(
      begin: 0.4,
      end: 0.7,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsating glow
            Transform.scale(
              scale: scaleAnimation.value,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white
                      .withAlpha((opacityAnimation.value * 255).toInt()),
                ),
              ),
            ),
            // Static progress indicator
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
