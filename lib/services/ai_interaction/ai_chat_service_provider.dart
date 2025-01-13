import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/language_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/ai_request_executor.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/langgraph_service.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_config_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/last_ai_message_listener_provider.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_type.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/repositories/ai_chat_messages_repository.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/repositories/ai_chat_threads_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_editing_note_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';

import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_editing_task_state_provider.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_notifier.dart';

final log = Logger('AIChatService');

final isAiRespondingProvider = StateProvider<bool>((ref) => false);

final isAiEditingProvider = StateProvider<bool>((ref) => false);

final aiChatServiceProvider = Provider<AIChatService>(AIChatService.new);

/*

TODO p1: fix bug where ai keeps speaking 

*/

/// Intermediary with LangGraph API
class AIChatService {
  final Ref ref;

  AIChatService(this.ref);

  Future<void> sendMessageToAi(String message) async {
    final isAiRespondingNotifier = ref.read(isAiRespondingProvider.notifier);
    final curOrgId = ref.read(curSelectedOrgIdNotifierProvider);
    final curUser = ref.read(curUserProvider).value;
    final aiChatMessagesRepo = ref.read(aiChatMessagesRepositoryProvider);

    isAiRespondingNotifier.state = true;

    if (curUser == null || curOrgId == null) {
      isAiRespondingNotifier.state = false;
      throw Exception('No current user or org id found');
    }

    try {
      // Get or create thread
      final aiChatThread = await _getOrCreateAiChatThread(curUser.id, curOrgId);

      // TODO p0: get UI context and send it message
      final uiContext = _getUIContext();

      // Save user message
      await aiChatMessagesRepo.insertItem(AiChatMessageModel(
          content: message,
          type: AiChatMessageType.user,
          parentChatThreadId: aiChatThread.id));

      // Send message to Langgraph
      await _runAi(
          aiChatThread: aiChatThread,
          userMessage: message,
          uiContext: uiContext);

      isAiRespondingNotifier.state = false;
    } catch (e) {
      rethrow;
    } finally {
      isAiRespondingNotifier.state = false;
    }
  }

  String _getUIContext() {
    final curRoute = ref.read(currentRouteProvider);

    final appRoute = AppRoutes.fromString(curRoute);

    if (appRoute == null) {
      return '';
      //print('AppRoute: ${appRoute.toString()}');
    }

    final sb = StringBuffer();
    sb.writeln('CurPage: $curRoute\n');

    //final curUser = ref.read(curUserProvider).value;
    //sb.writeln('CurUser: ${curUser?.email}\n');

    if (appRoute == AppRoutes.taskPage) {
      final curTask = ref.read(curEditingTaskStateProvider).value;
      sb.writeln('CurTask: ${curTask?.taskModel.toAiReadableMap()}');
    } else if (appRoute == AppRoutes.notePage) {
      final curNoteMap =
          ref.read(curEditingNoteStateProvider.notifier).toReadableMap();
      sb.writeln('CurNote: $curNoteMap');
    }

    return sb.toString();
  }

  Future<void> _runAi({
    required AiChatThreadModel aiChatThread,
    String? userMessage,
    String? uiContext,
  }) async {
    final langgraphService = ref.read(langgraphServiceProvider);
    final lastAiMessageListener =
        ref.read(lastAiMessageListenerProvider.notifier);
    final aiChatMessagesRepo = ref.read(aiChatMessagesRepositoryProvider);

    // Call Langgraph API
    final lgBaseMessages = await langgraphService.runAi(
      message: userMessage,
      uiContext: uiContext,
      lgThreadId: aiChatThread.parentLgThreadId,
      lgAssistantId: aiChatThread.parentLgAssistantId,
    );

    // Convert lgBaseMessages as aiChatMessages
    final aiChatMessages = lgBaseMessages
        .map((lgBaseMessage) => AiChatMessageModel(
            content: lgBaseMessage.content,
            type: AiChatMessageTypeExtension.fromLgAiChatMessageRole(
                lgBaseMessage.type),
            parentChatThreadId: aiChatThread.id))
        .toList();

    // Display ai response
    // For Groq - a tool call does not provide a message
    if (aiChatMessages.isNotEmpty) {
      lastAiMessageListener.addAiChatMessage(aiChatMessages.first);
      if (!isWebVersion) speakAiMessage(aiChatMessages);
    }

    // Save response to DB
    await aiChatMessagesRepo.insertItems(aiChatMessages);

    // Execute request if needed
    await _tryExecuteAiRequests(aiChatThread, aiChatMessages);
  }

  Future<void> _tryExecuteAiRequests(AiChatThreadModel aiChatThread,
      List<AiChatMessageModel> aiChatMessages) async {
    final lastAiMessageListener =
        ref.read(lastAiMessageListenerProvider.notifier);
    final aiRequestExecutor = ref.read(aiRequestExecutorProvider);
    final aiChatMessagesRepo = ref.read(aiChatMessagesRepositoryProvider);
    final langGraphService = ref.read(langgraphServiceProvider);

    // === Check if Execution is needed ===

    if (aiChatMessages.isEmpty) {
      return;
    }

    // Read the chat response and identify ToolMessages
    List<AiRequestModel>? toolResponses = aiChatMessages
        .where((msg) => msg.isAiRequest())
        .expand((msg) => [msg.getAiRequest()!])
        .toList() as List<AiRequestModel>?;

    if (toolResponses == null || toolResponses.isEmpty) {
      return;
    }

    if (toolResponses.length > 1) {
      log.warning(
          'Multiple tool responses found in executeAiChatMessages, ignoring all but the first');
    }

    // === Execute Request ===
    final result = await aiRequestExecutor.executeAiRequest(toolResponses[0]);

    // Display Result
    // final isCallAgain = result.showOnly ? '' : '<AI CALLED AGAIN>';
    // lastAiMessageListener.addLastToolResponseResult(result.copyWith(
    //     message: '$isCallAgain${result.resultForAi}', showOnly: result.showOnly));
    // //speakAiMessage(aiChatMessages);

    // Save Result to DB
    final aiResultMessage = AiChatMessageModel(
        content: jsonEncode(result.toJson()),
        type: AiChatMessageType.tool,
        parentChatThreadId: aiChatThread.id);

    await aiChatMessagesRepo.insertItem(aiResultMessage);

    lastAiMessageListener.addAiChatMessage(aiResultMessage);

    // Update LangGraph's Memory with the result of the request
    await langGraphService.updateLastToolMessageWithResult(
      resultString: result.resultForAi,
      showOnly: result.showOnly,
      lgThreadId: aiChatThread.parentLgThreadId,
      lgAssistantId: aiChatThread.parentLgAssistantId,
    );

    // Check if AI should call again
    if (result.showOnly) {
      return;
    }

    // === Send Result to LangGraph for Followup ===

    await _runAi(
        aiChatThread: aiChatThread, userMessage: null, uiContext: null);
  }

  Future<AiChatThreadModel> _getOrCreateAiChatThread(
      String userId, String orgId) async {
    final aiChatThreadsRepo = ref.read(aiChatThreadsRepositoryProvider);
    final langgraphService = ref.read(langgraphServiceProvider);
    final curOrgId = ref.read(curSelectedOrgIdNotifierProvider);
    final curUser = ref.read(curUserProvider).value;

    final existingThread = await aiChatThreadsRepo.getUserThread(
      userId: userId,
      orgId: orgId,
    );

    if (existingThread != null) {
      return existingThread;
    }

    // TODO p3: get org name for assistant name
    final name = '${curUser!.email} - $curOrgId';

    // Get timezone offset string
    final timezoneOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    final language = ref.read(languageSNP);

    // Create new thread and assistant
    final (newLgThreadId, newLgAssistantId) =
        await langgraphService.createNewThread(
      name: name,
      lgConfig: LgConfigSchemaModel(
        timezoneOffsetMinutes: timezoneOffsetMinutes,
        language: language,
        orgId: orgId,
        userId: userId,
      ),
    );

    final newThread = AiChatThreadModel(
      authorUserId: userId,
      parentLgThreadId: newLgThreadId,
      parentLgAssistantId: newLgAssistantId,
      parentOrgId: orgId,
    );

    await aiChatThreadsRepo.insertItem(newThread);

    return newThread;
  }

  Future<void> speakAiMessage(List<AiChatMessageModel> result) async {
    final textToSpeech = ref.read(textToSpeechServiceProvider.notifier);

    final aiMessage = result.firstWhereOrNull((element) =>
        element.type == AiChatMessageType.ai && element.content.isNotEmpty);

    if (aiMessage == null) {
      return;
    }

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
