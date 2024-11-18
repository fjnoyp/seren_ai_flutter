import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_listen_state_provider.dart';

// Display transcribed text
class SpeechTranscribedWidget extends ConsumerWidget {
  const SpeechTranscribedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textState = ref.watch(speechToTextListenStateProvider);

    return Visibility(
      visible: textState.text.isNotEmpty,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.dividerColor, // Use theme color for border
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10), // Added rounded corners
          color: theme.highlightColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  textState.text,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
