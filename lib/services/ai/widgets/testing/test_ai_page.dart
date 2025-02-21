import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/langgraph_service.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_config_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';

class TestAiPage extends HookConsumerWidget {
  const TestAiPage({super.key});

  Future<String> createAssistant(String curUserId, String curOrgId,
      LanggraphService langgraphService) async {
    final config = LgConfigSchemaModel(
      //userId: curUserId,
      //orgId: curOrgId,
      timezoneOffsetMinutes: 30,
      //language: 'pt',
    );

    final assistantId = await langgraphService.langgraphApi.createAssistant(
      name: 'Test Assistant',
      lgConfig: config,
    );

    return assistantId;
  }

  Future<String> getAssistants(String curUserId, String curOrgId,
      LanggraphService langgraphService) async {
    final config = LgConfigSchemaModel(
      //userId: curUserId,
      //orgId: curOrgId,
      timezoneOffsetMinutes: 30,
      //language: 'pt',
    );

    final assistants = await langgraphService.langgraphApi.searchAssistants(
      metadata: config.toJson(),
    );

    // convert to string list of ids
    final assistantIds =
        assistants.map((assistant) => assistant.assistantId).toList();

    return assistantIds.join(', ');
  }

  Future<void> deleteAllAssistants(LanggraphService langgraphService) async {
    final assistants = await langgraphService.langgraphApi.searchAssistants();

    for (final assistant in assistants) {
      await langgraphService.langgraphApi
          .deleteAssistant(assistant.assistantId);
    }
  }

  Future<String> getThreads(LanggraphService langgraphService) async {
    final threads = await langgraphService.langgraphApi.searchThreads();
    return threads.map((thread) => thread.threadId).toList().join(', ');
  }

  Future<void> deleteAllThreads(LanggraphService langgraphService) async {
    final threads = await langgraphService.langgraphApi.searchThreads();

    for (final thread in threads) {
      await langgraphService.langgraphApi.deleteThread(thread.threadId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responseState = useState<String?>(null);
    final langgraphService = ref.watch(langgraphServiceProvider);
    final curUserId = ref.read(curUserProvider).value!.id;
    final curOrgId = ref.read(curSelectedOrgIdNotifierProvider)!;

    final aiChatService = ref.watch(aiChatServiceProvider);

    Widget _buildDebugButton({
      required String label,
      required Future<void> Function() onPressed,
      String? successMessage,
    }) {
      return SizedBox(
        width: 350,
        child: ElevatedButton(
          onPressed: () async {
            try {
              await onPressed();
              if (successMessage != null) {
                responseState.value = successMessage;
              }
            } catch (e) {
              responseState.value =
                  'Error: ${e.toString()}\nStack Trace: ${StackTrace.current}';
            }
          },
          child: Text(label),
        ),
      );
    }

    return Column(
      children: [
        const Text('Debug Page'),
        _buildDebugButton(
          label: 'Test Single Call',
          onPressed: () async {
            final messages = await aiChatService.sendSingleCallMessageToAi(
              systemMessage: 'Respond in French only',
              userMessage: 'Pourquoi est-il difficile de parler français?',
            );
            responseState.value = 'Messages: $messages';
          },
        ),
        _buildDebugButton(
          label: 'Test Create Assistant',
          onPressed: () async {
            final assistantId =
                await createAssistant(curUserId, curOrgId, langgraphService);
            responseState.value = 'Created Assistant: $assistantId';
          },
        ),
        _buildDebugButton(
          label: 'Test Get Assistants',
          onPressed: () async {
            final assistantIds =
                await getAssistants(curUserId, curOrgId, langgraphService);
            responseState.value = 'Found Assistants: $assistantIds';
          },
        ),
        _buildDebugButton(
          label: 'Test Delete All Assistants',
          onPressed: () => deleteAllAssistants(langgraphService),
          successMessage: 'Deleted All Assistants',
        ),
        _buildDebugButton(
          label: 'Test Get Threads',
          onPressed: () async {
            final threads = await getThreads(langgraphService);
            responseState.value = 'Found Threads: $threads';
          },
        ),
        _buildDebugButton(
          label: 'Test Delete All Threads',
          onPressed: () => deleteAllThreads(langgraphService),
          successMessage: 'Deleted All Threads',
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
