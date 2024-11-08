import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/ai_request_executor.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_info_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/langgraph_service.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/test_langgraph_api.dart';

import 'package:seren_ai_flutter/services/ai_interaction/widgets/ai_results_widget.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_state_control_button_widget.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_transcribed_widget.dart';

final textFieldVisibilityProvider = StateProvider<bool>((ref) => false);

/// Class to display user's voice input or manual text input
///
class UserInputDisplayWidget extends ConsumerWidget {
  const UserInputDisplayWidget(this.isAiAssistantExpanded, {super.key});

  final ValueNotifier<bool> isAiAssistantExpanded;

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => isAiAssistantExpanded.value = false,
                  icon: const Icon(Icons.close),
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final isAiResponding = ref.watch(isAiRespondingProvider);
                  return Visibility(
                    visible: isAiResponding,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary),
                    ),
                  );
                },
              ),
              const TestLanggraphWidget(),
              const AiResultsWidget(),
              const SpeechTranscribedWidget(),
              ref.read(textFieldVisibilityProvider.notifier).state
                  ? UserInputTextDisplayWidget()
                  : const SpeechStateControlButtonWidget(),
              SizedBox(height: keyboardHeight), // Add space for the keyboard
              IconButton(
                icon: Icon(isTextFieldVisible ? Icons.mic : Icons.keyboard),
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

class TestLanggraphWidget extends HookConsumerWidget {
  const TestLanggraphWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responseState = useState<String?>(null);

    final langgraphService = ref.watch(langgraphServiceProvider);

    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            try {
              final curUser = ref.read(curUserProvider).value;

              final curOrg = ref.read(curOrgDependencyProvider);

              // final user2Id = '8c518695-0278-4a0d-9727-136eec2f71c3';

              //  final result = await langgraphService.langgraphDbOperations
              //      .getOrCreateAiChatThread(user2Id, curOrg!);

              // final result = await langgraphService.sendUserMessage(
              //     'what is my shift today?', curUser!.id, curOrg!);

              // final result = await langgraphService.langgraphApi.getThreadState(
              //  'c55a9029-ef0b-4160-b0d5-bce5e0930be2',               
              // );

              // final showMessages = result.messages.sublist(result.messages.length - 3);

              // responseState.value = showMessages
              //     .map((message) => message.toJson().toString())
              //     .join('\n\n') // Add space formatting between each message
              //     .toString();

              final result = await langgraphService.updateLastToolMessageThreadState(
                lgThreadId: '5c94df24-cdc4-43e0-98fa-1dc4dc74393c',
                result: LgAiRequestResultModel(
                  showOnly: false,
                  message: 'Shifts from 5-8 pm',
                ),
              );

              // final result = await langgraphService.sendAiRequestResult(
              //   curUser!.id,
              //   curOrg!,
              //   LgAiRequestResultModel(
              //     showOnly: false,
              //     message: 'Shifts from 5-8 pm',
              //   ),
              // );

              // responseState.value = result
              //     .map((message) => message.toJson().toString())
              //     .toList()
              //     .toString();
              
            } catch (e) {
              responseState.value = 'Error: ${e.toString()}\nStack Trace: ${StackTrace.current}';
            }
          },
          child: const Text('Test Get Run'),
        ),
        if (responseState.value != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText('Response: ${responseState.value}'),
          ),
      ],
    );
  }
}

class TestAiWidget extends HookConsumerWidget {
  const TestAiWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responseState = useState<String?>(null);
    final isVisible = useState<bool>(true); // State to show/hide contents

    final requestShiftInfo =
        AiInfoRequestModel(infoRequestType: AiInfoRequestType.currentShift);
    final requestClockIn =
        AiActionRequestModel(actionRequestType: AiActionRequestType.clockIn);
    final requestClockOut =
        AiActionRequestModel(actionRequestType: AiActionRequestType.clockOut);
    final List<AiRequestModel> testToolResponses = [
      requestShiftInfo,
      requestClockOut
    ];

    return Container(
      padding: const EdgeInsets.all(4), // Reduced padding
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(isVisible.value
                    ? Icons.hide_source
                    : Icons.bug_report_outlined),
                onPressed: () {
                  isVisible.value = !isVisible.value; // Toggle visibility
                },
              ),
            ],
          ),
          if (isVisible.value) ...[
            ElevatedButton(
              onPressed: () async {
                try {
                  final results = await ref
                      .read(aiRequestExecutorProvider)
                      .executeAiRequest(testToolResponses[0]);
                  responseState.value = results.message;
                } catch (e) {
                  responseState.value = e.toString();
                }
              },
              child: const Text('Execute Ai Request'),
            ),
            if (responseState.value != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0), // Added padding
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.blue, width: 1), // Blue border
                  borderRadius:
                      BorderRadius.circular(6), // Smaller rounded corners
                ),
                child: Text('Response: ${responseState.value}'),
              ),
            ],
          ],
        ],
      ),
    );
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
