import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_tool_response_executor.dart';
import 'package:seren_ai_flutter/services/ai_interaction/last_ai_message_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_state_control_button_widget.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_transcribed_widget.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_notifier.dart';

final textFieldVisibilityProvider = StateProvider<bool>((ref) => false);

/// Class to display user's voice input or manual text input
///
class UserInputDisplayWidget extends ConsumerWidget {
  const UserInputDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTextFieldVisible = ref.watch(textFieldVisibilityProvider);
    final theme = Theme.of(context);
    
    // Get the height of the keyboard
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Card(
        color: theme.cardColor,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final isAiResponding = ref.watch(isAiRespondingProvider);
                  return Visibility(
                    visible: isAiResponding,
                    child: 
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                            ),
                  );
                },
              ),
              const DisplayAiResultsWidget(),
              const SpeechTranscribedWidget(),
              const SpeechStateControlButtonWidget(),
              UserInputTextDisplayWidget(),
              SizedBox(height: keyboardHeight), // Add space for the keyboard
              IconButton(
                icon: Icon(isTextFieldVisible ? Icons.cancel : Icons.keyboard),
                onPressed: () {
                  ref.read(textFieldVisibilityProvider.notifier).state =
                      !isTextFieldVisible;
                },
              ),
              // You can add more widgets here if needed
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayAiResultsWidget extends HookConsumerWidget {
  const DisplayAiResultsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {    
    final lastAiMessages = ref.watch(lastAiMessageListenerProvider);    
    final isVisible = useState(lastAiMessages.isNotEmpty);

    useEffect(() {
      if (lastAiMessages.isNotEmpty) {
        isVisible.value = true;
      }
      return null;
    }, [lastAiMessages]);

    return Visibility(
      visible: isVisible.value, 
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  itemCount: lastAiMessages.length,
                  itemBuilder: (context, index) {
                    return DisplayAiResultWidget(aiResult: lastAiMessages[index]);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                onPressed: () {
                  isVisible.value = false;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayAiResultWidget extends ConsumerWidget {
  final AiResult aiResult;
  const DisplayAiResultWidget({super.key, required this.aiResult});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String displayText = '';
    
    if (aiResult is AiChatMessageModel) {
      displayText = (aiResult as AiChatMessageModel).content;
    } else if (aiResult is ToolResponseResult) {
      displayText = (aiResult as ToolResponseResult).message;
    }

    return Text(displayText);
  }
}

class UserInputTextDisplayWidget extends ConsumerWidget {
  final TextEditingController textEditingController = TextEditingController();

  UserInputTextDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTextFieldVisible = ref.watch(textFieldVisibilityProvider);
    final theme = Theme.of(context);

    return Visibility(
      visible: isTextFieldVisible,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.dividerColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: theme.highlightColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: textEditingController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Enter something',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: theme.textTheme.bodySmall?.color ?? Colors.black,
                  ),
                ),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodySmall?.color ?? Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.check_box_outlined, size: 20),
                  onPressed: () async {

                    ref.read(textFieldVisibilityProvider.notifier).state =
                        false;

                    await ref
                        .read(aiChatServiceProvider)
                        .sendMessage(textEditingController.text);

                    textEditingController.clear();
                  },
                  color: theme.colorScheme.primary,
                ),
                IconButton(
                  icon: Icon(Icons.close_outlined, size: 20),
                  onPressed: () {
                    ref.read(textFieldVisibilityProvider.notifier).state =
                        false;
                    textEditingController.clear();
                  },
                  color: theme.colorScheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
