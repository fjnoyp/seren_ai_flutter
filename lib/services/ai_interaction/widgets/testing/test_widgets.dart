import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/langgraph_service.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_config_model.dart';

import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';

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

              final curOrg = ref.read(curSelectedOrgIdNotifierProvider);

              final assistantId =
                  await langgraphService.langgraphApi.createAssistant(
                name: 'Test Assistant',
                lgConfig: LgConfigSchemaModel(
                  userId: curUser!.id,
                  orgId: curOrg!,
                  timezoneOffsetMinutes: 30,
                  language: 'pt',
                ),
              );

              responseState.value = assistantId;

              // final user2Id = '8c518695-0278-4a0d-9727-136eec2f71c3';

              //  final result = await langgraphService.langgraphDbOperations
              //      .getOrCreateAiChatThread(user2Id, curOrg!);

              // final result = await langgraphService.sendUserMessage(
              //     'what is my shift today?', curUser!.id, curOrg!);

              // final result = await langgraphService.langgraphApi.getThreadState(
              //  'fbb8ef11-5f6b-4d28-a12a-1facb2969d98',
              // );

              // final showMessages = result.messages.sublist(result.messages.length - 3);

              // responseState.value = showMessages
              //     .map((message) => message.toJson().toString())
              //     .join('\n\n') // Add space formatting between each message
              //     .toString();

              // final result = await langgraphService.updateLastToolMessageThreadState(
              //   lgThreadId: 'fbb8ef11-5f6b-4d28-a12a-1facb2969d98',
              //   result: LgAiRequestResultModel(
              //     showOnly: false,
              //     message: 'Shifts from 5-8 pm',
              //   ),
              // );

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
              responseState.value =
                  'Error: ${e.toString()}\nStack Trace: ${StackTrace.current}';
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
                // try {
                //   final results = await ref
                //       .read(aiRequestExecutorProvider)
                //       .executeAiRequest(testToolResponses[0]);
                //   responseState.value = results.message;
                // } catch (e) {
                //   responseState.value = e.toString();
                // }
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
