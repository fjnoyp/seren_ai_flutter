import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_listen_state_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_service_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_status_provider.dart';

// Display current heard volume
class SpeechVolumeWidget extends ConsumerWidget {
  const SpeechVolumeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textState = ref.watch(speechToTextListenStateProvider);
    final statusState = ref.watch(speechToTextStatusProvider);
    final soundLevel =
        statusState.speechState == SpeechToTextStateEnum.listening
            ? textState.soundLevel.abs()
            : 0.0;
    final theme = Theme.of(context);

    return Container(
      width: 64 + soundLevel,
      height: 64 + soundLevel,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.cardColor,
        border: Border.all(
          color: theme.primaryColorLight,
          width: 2.0,
        ),
      ),
    );
  }
}
