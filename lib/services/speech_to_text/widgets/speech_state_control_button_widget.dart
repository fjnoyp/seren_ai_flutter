import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_listen_state_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_service_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_status_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_volume_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_notifier.dart';

// Button to start/stop listening
class SpeechStateControlButtonWidget extends ConsumerWidget {
  static const _size = 80.0;

  const SpeechStateControlButtonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusState = ref.watch(speechToTextStatusProvider);
    final notifier = ref.read(speechToTextListenStateProvider.notifier);

    final theme = Theme.of(context);

    if (statusState.isInitialized) {
      Widget centerWidget;
      ({Icon icon, VoidCallback onTap})? leftButton;
      ({Icon icon, VoidCallback onTap})? rightButton;
      String label = '';

      switch (statusState.speechState) {
        case SpeechToTextStateEnum.listening:
          centerWidget = Stack(
            alignment: Alignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: const SpeechVolumeWidget(),
              ),
              IconButton(
                icon: const Icon(Icons.send, size: 48),
                onPressed: () => notifier.sendText(ref),
              ),
            ],
          );
          label = 'Tap to send';
          leftButton = (
            icon: const Icon(Icons.close),
            onTap: () => notifier.cancelListening(),
          );
          rightButton = (
            icon: const Icon(Icons.pause),
            onTap: () => notifier.stopListening()
          );
          break;
        case SpeechToTextStateEnum.notListening:
        case SpeechToTextStateEnum.done:
        case SpeechToTextStateEnum.available:
          final isPaused =
              ref.watch(speechToTextListenStateProvider).text.isNotEmpty;
          centerWidget = IconButton.filled(
            style: IconButton.styleFrom(
              // backgroundColor: Theme.of(context).primaryColor,
              iconSize: 48,
              padding: const EdgeInsets.all(16),
            ),
            icon: const Icon(Icons.mic),
            onPressed: () async {
              await ref.watch(textToSpeechServiceProvider.notifier).stop();
              isPaused ? notifier.resumeListening() : notifier.startListening();
            },
          );
          if (isPaused) {
            label = 'Tap to resume';
            leftButton = (
              icon: const Icon(Icons.delete),
              onTap: () => notifier.cancelListening(),
            );
            rightButton = (
              icon: const Icon(Icons.send),
              onTap: () => notifier.sendText(ref),
            );
          } else {
            label = 'Tap to talk';
            leftButton = null;
            rightButton = null;
          }

          break;
        case SpeechToTextStateEnum.startListening:
        case SpeechToTextStateEnum.startNotListening:
          centerWidget = SizedBox(
            width: _size,
            height: _size,
            child: CircularProgressIndicator(
              strokeWidth: 12.0,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              backgroundColor: theme.primaryColorLight,
            ),
          );
          label = 'Loading...';
          leftButton = null;
          rightButton = null;
          break;
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              leftButton != null
                  ? IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      icon: leftButton.icon,
                      onPressed: leftButton.onTap,
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                height: _size,
                child: centerWidget,
              ),
              rightButton != null
                  ? IconButton.filled(
                      style: IconButton.styleFrom(
                          // backgroundColor: Theme.of(context).colorScheme.surface,
                          ),
                      icon: rightButton.icon,
                      onPressed: rightButton.onTap,
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      );
    } else {
      if (statusState.error.isEmpty) {
        return const CircularProgressIndicator();
      } else {
        return Text(AppLocalizations.of(context)!.initError(statusState.error));
      }
    }
  }
}
