import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_listen_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_service_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_status_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_volume_widget.dart';


// Button to start/stop listening
class SpeechStateControlButtonWidget extends ConsumerWidget {
  const SpeechStateControlButtonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusState = ref.watch(speechToTextStatusProvider);
    final notifier = ref.read(speechToTextListenProvider.notifier);

    final theme = Theme.of(context);

    if (statusState.isInitialized) {
      List<Widget> columnChildren = [];

      Widget topView;

      switch (statusState.speechState) {
        case SpeechToTextStateEnum.listening:
          topView = Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor, // Use theme color
                  shape: BoxShape.circle, // Circular shape
                ),
                width: 80.0,
                height: 80.0,
                child: IconButton(
                  icon: const Icon(Icons.square_outlined,
                      size: 50.0, color: Colors.white),
                  onPressed: () => notifier.stopListening(),
                ),
              ),
              Positioned(
                top: -10,
                right: -10,
                child: CircleAvatar(
                  backgroundColor:
                      Colors.white, // Set background color to white
                  radius:
                      20, // Half of the width and height to make a perfect circle
                  child: IconButton(
                    iconSize: 40, // Adjust the icon size as needed
                    padding: EdgeInsets
                        .zero, // Remove padding to allow the icon to fill the button
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => notifier.cancelListening(),
                  ),
                ),
              ),
            ],
          );
          break;
        case SpeechToTextStateEnum.notListening:
        case SpeechToTextStateEnum.done:
        case SpeechToTextStateEnum.available:
          topView = Container(
              decoration: BoxDecoration(
                color: theme.primaryColor, // Use theme color
                shape: BoxShape.circle, // Circular shape
              ),
              width: 80.0,
              height: 80.0,
              child: IconButton(
                icon:
                    const Icon(Icons.mic_none, size: 50.0, color: Colors.white),
                onPressed: () => notifier.startListening(),
              ));

          break;
        case SpeechToTextStateEnum.startListening:
        case SpeechToTextStateEnum.startNotListening:
          topView = SizedBox(
            width: 80.0,
            height: 80.0,
            child: CircularProgressIndicator(
              strokeWidth: 12.0,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              backgroundColor: theme.primaryColorLight,
            ),
          );
          break;
        default:
          topView = Text('Unknown state: ${statusState.speechState}');
      }

      columnChildren.add(topView);

      columnChildren.addAll([
        const SizedBox(height: 5), // Added space between the mic and the bar
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: const SpeechVolumeWidget(),
          ),
        ),
      ]);

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: columnChildren),
          ),
        ],
      );
    } else {
      if (statusState.error.isEmpty) {
        return const CircularProgressIndicator();
      } else {
        return Text('Init error: ${statusState.error}');
      }
    }
  }
}
