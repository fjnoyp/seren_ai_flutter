import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_listen_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_service_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_status_provider.dart';


// Display current heard volume
class SpeechVolumeWidget extends ConsumerWidget {
  const SpeechVolumeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textState = ref.watch(speechToTextListenProvider);
    final statusState = ref.watch(speechToTextStatusProvider);
    final soundLevel =
        statusState.speechState == SpeechToTextStateEnum.listening
            ? textState.soundLevel.abs() / 100
            : 0.0;
    final theme = Theme.of(context);

    return LinearProgressIndicator(
      minHeight: 8,
      value: soundLevel,
      backgroundColor: theme.colorScheme.surface,
      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColorLight),
    );
  }
}
