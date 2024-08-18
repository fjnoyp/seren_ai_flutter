import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_listen_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_service_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_status_provider.dart';


// Display transcribed text
class SpeechTranscribedWidget extends ConsumerWidget {
  const SpeechTranscribedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textState = ref.watch(speechToTextListenProvider);
    final statusState = ref.watch(speechToTextStatusProvider);

    if (statusState.speechState == SpeechToTextStateEnum.listening) {
      return Container(
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
                  textState.text.isEmpty ? '...' : textState.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodySmall?.color ?? Colors.black),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
