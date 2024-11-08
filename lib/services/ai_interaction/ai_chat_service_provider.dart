import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/ai_request_executor.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/langgraph_service.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_base_message_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/last_ai_message_listener_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/testing/sample_ai_chat_message_models.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_service_provider.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

import 'package:logging/logging.dart';

final log = Logger('AIChatService');

final isAiRespondingProvider = StateProvider<bool>((ref) => false);

final isAiEditingProvider = StateProvider<bool>((ref) => false);

final aiChatServiceProvider = Provider<AIChatService>(AIChatService.new);


/*
TODO: 

1. ideally move out langgraph_db_operations 
2. have an intermediate class dedicated to converting from our data to langgraph data 
3. in showOnly case - still store the result in the db 
6. do not pass ref directly to service classes! 

*/
class AIChatService {
  final Ref ref;

  AIChatService(this.ref);

  Future<List<AiChatMessageModel>> sendAiRequestResult(
      AiRequestResultModel aiRequestResult) async {
    final curOrgId = ref.watch(curOrgIdProvider);
    final curUser = ref.read(curUserProvider).value;

    if (curUser == null || curOrgId == null) {
      throw Exception('No current user or org id found');
    }

    final aiChatMessages = await ref
        .read(langgraphServiceProvider)
        .sendAiRequestResult(curUser.id, curOrgId, aiRequestResult);

    ref
        .read(lastAiMessageListenerProvider.notifier)
        .addLastAiMessage(aiChatMessages.first);

    // Tip: When testing ai request execution - you can hardcode the aiChatMessages to test different flows
    await executeAiRequests(aiChatMessages);

    return aiChatMessages;
  }

  Future<List<AiChatMessageModel>> sendMessage(String message) async {
    ref.read(isAiRespondingProvider.notifier).state = true;

    final curOrgId = ref.read(curOrgIdProvider);
    final curUser = ref.read(curUserProvider).value;

    if (curUser == null || curOrgId == null) {
      ref.read(isAiRespondingProvider.notifier).state = false;
      throw Exception('No current user or org id found');
    }

    try {
      List<AiChatMessageModel> aiChatMessages = [];

      aiChatMessages = await ref
          .read(langgraphServiceProvider)
          .sendUserMessage(message, curUser.id, curOrgId);

      ref
          .read(lastAiMessageListenerProvider.notifier)
          .addLastAiMessage(aiChatMessages.first);

      // Tip: When testing ai request execution - you can hardcode the aiChatMessages to test different flows
      await executeAiRequests(aiChatMessages);

      ref.read(isAiRespondingProvider.notifier).state = false;

      await speakAiMessage(aiChatMessages);

      return aiChatMessages;
    } catch (e) {
      ref.read(isAiRespondingProvider.notifier).state = false;
      rethrow;
    } finally {
      ref.read(isAiRespondingProvider.notifier).state = false;
    }
  }

  Future<void> executeAiRequests(
      List<AiChatMessageModel> aiChatMessages) async {
    // TODO p0: update last ai message provider to be manually updated by the code flow here

    // Read the chat response and identify ToolMessages
    List<AiRequestModel>? toolResponses = aiChatMessages
        .where((msg) => msg.isAiToolRequest())
        .expand((msg) => [msg.getAiRequest()!])
        .toList() as List<AiRequestModel>?;

    if (toolResponses != null && toolResponses.isNotEmpty) {
      if (toolResponses.length > 1) {
        log.warning(
            'Multiple tool responses found in executeAiChatMessages, ignoring all but the first');
      }

      final result = await ref
          .read(aiRequestExecutorProvider)
          .executeAiRequest(toolResponses[0]);

      if (result.showOnly) {
        ref
            .read(lastAiMessageListenerProvider.notifier)
            .addLastToolResponseResult(result);
      } else {
        ref
            .read(lastAiMessageListenerProvider.notifier)
            .addLastToolResponseResult(result.copyWith(
                message: '<AI CALLED AGAIN>${result.message}',
                showOnly: false));

        final followupMessages = await sendAiRequestResult(result);

        ref
            .read(lastAiMessageListenerProvider.notifier)
            .addLastAiMessage(followupMessages.first);
      }
    }
  }

  Future<void> speakAiMessage(List<AiChatMessageModel> result) async {
    // TODO: consolidate duplicated code from stt_orchestrator_provider.dart
    final aiMessage = result.firstWhereOrNull((element) =>
        element.type == AiChatMessageType.ai && element.content.isNotEmpty);

    if (aiMessage == null) {
      return;
    }

    final textToSpeech = ref.read(textToSpeechServiceProvider);
    await textToSpeech.speak(aiMessage.content);
  }
}



/*


  List<AiChatMessageModel> _getTestAiChatMessages() {
    final allMessages = [
      sampleClockInRequest,
      sampleClockOutRequest,
      sampleCurrentShiftInfoRequest,
      sampleShiftHistoryRequest, // TBD
      sampleShiftsPageRequest // TBD
    ];
    return [sampleClockOutRequest];
  }

  Future<void> testAiCreateTask(BuildContext context) async {
    // TEST calling Supabase Edge Function
    final supabase = Supabase.instance.client;

    ref.read(isAiEditingProvider.notifier).state = true;

    await openBlankTaskPage(context, ref);

    print('openTaskPage done');

    await Future.delayed(Duration(milliseconds: 250));

    final joinedTask = JoinedTaskModel(
      task: TaskModel(
        name: 'AI Set Task Test',
        dueDate: DateTime.now().toUtc(),
        parentProjectId: 'parentProjectId',
        description: 'Task description',
        status: StatusEnum.inProgress,
        authorUserId: 'authorUserId',
      ),
      authorUser: UserModel(
        id: 'authorUserId',
        email: 'ai@seren.ai',
        parentAuthUserId: 'parentAuthUserId',
      ),

      // TODO p1: allow managers/admins to assign a user to a project/team so they don't have to worry about any selection

      // Team is just for gropuing users
      // Tasks are only assigned based on project permissions

      // https://miro.com/app/board/uXjVKCs7dtw=/?utm_source=notification&utm_medium=email&utm_campaign=daily-updates&utm_content=view-board-cta

      project: ProjectModel(
        id: 'projectId',
        name: 'TEST',
        description: 'test',
        parentOrgId: 'parentOrgId',
      ),
      assignees: [
        UserModel(
          id: 'assigneeUserId',
          email: 'ai@seren.ai',
          parentAuthUserId: 'parentAuthUserId',
        ),
      ],
      comments: [],
    );

    ref.read(curTaskServiceProvider).loadTask(joinedTask);

    //test();

    // Delay setting isAiEditingProvider to false to ensure animation is triggered
    await Future.delayed(Duration(milliseconds: 500));

    ref.read(isAiEditingProvider.notifier).state = false;
  }
  */