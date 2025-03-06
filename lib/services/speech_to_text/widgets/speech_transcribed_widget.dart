import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_overlay_container.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_ai_assistant_overlay_manager.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_listen_state_provider.dart';

/// Displays the transcribed speech from the speech to text service
class SpeechTranscribedWidget extends HookConsumerWidget {
  const SpeechTranscribedWidget({super.key});

  /// Show this widget as an overlay
  static void show(BuildContext context, GlobalKey anchorKey) {
    MobileAiAssistantOverlayManager.show(
      context: context,
      type: AiAssistantOverlayType.transcription,
      anchorKey: anchorKey,
      builder: (context) => const SpeechTranscribedWidget(),
    );
  }

  /// Hide this overlay
  static void hide() {
    MobileAiAssistantOverlayManager.hide(AiAssistantOverlayType.transcription);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechState = ref.watch(speechToTextListenStateProvider);
    final text = speechState.text;

    // Nothing to show if no text
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: MobileOverlayContainer(
        child: SingleChildScrollView(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
