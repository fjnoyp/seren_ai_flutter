import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_responding_provider.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/ai_request_executor.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_request_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/langgraph_service.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_ai_base_message_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_command_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_config_model.dart';
import 'package:seren_ai_flutter/services/ai/last_ai_message_listener_provider.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/models/ai_chat_message_type.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/repositories/ai_chat_messages_repository.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/repositories/ai_chat_threads_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_selected_note_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/ai/ai_context_service.dart';

import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_notifier.dart';

final log = Logger('AIChatService');

// final isAiEditingProvider = StateProvider<bool>((ref) => false);

final aiChatServiceProvider = Provider<AIChatService>(AIChatService.new);

/*

TODO p1: fix bug where ai keeps speaking 

*/

/// Intermediary with LangGraph API
class AIChatService {
  final Ref ref;

  AIChatService(this.ref);

// TODO p2: raw lg message types should not be leaked to rest of code
// We should be handling types here instead ...
  Future<List<LgAiBaseMessageModel>> sendSingleCallMessageToAi({
    required String systemMessage,
    required String userMessage,
  }) async {
    final langgraphService = ref.read(langgraphServiceProvider);
    final lgBaseMessages = await langgraphService.runSingleCallAi(
      systemMessage: systemMessage,
      userMessage: userMessage,
    );

    return lgBaseMessages;
  }

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

      final uiContext = await _getUIContext();

      isAiRespondingNotifier.state = true;

      // Code to test hardcoded AI requests
      /*
      final aiRequestExecutor = ref.read(aiRequestExecutorProvider);

      await aiRequestExecutor.executeAiRequest(UpdateTaskFieldsRequestModel(
        taskName: 'AI Set Task Test',
        taskDueDate: DateTime.now().toUtc().toIso8601String(),
        taskDescription: 'Task description',
        taskStatus: 'inProgress',
        taskPriority: 'veryLow',
        assignedUserNames: ['authorUserId'],
      ));

      // await aiRequestExecutor.executeAiRequest(CreateTaskRequestModel(
      //   taskName: 'AI Set Task Test',
      //   taskDueDate: DateTime.now().toUtc().toIso8601String(),
      //   parentProjectName: 'parentProjectId',
      //   taskDescription: 'Task description',
      //   taskStatus: 'inProgress',
      //   taskPriority: 'high',
      //   assignedUserNames: ['authorUserId'],
      // ));
      */

      // Save user message
      await aiChatMessagesRepo.insertItem(
        AiChatMessageModel(
            content: message,
            type: AiChatMessageType.user,
            parentChatThreadId: aiChatThread.id,
            // We have to set this manually to avoid wrong ordering
            // with null values while waiting for DB to sync with supabase
            createdAt: DateTime.now().toUtc()),
      );

      // Send message to Langgraph
      await _runAi(
          aiChatThread: aiChatThread,
          userMessage: message,
          uiContext: uiContext);

      // Add small delay to ensure color animation can be triggered
      await Future.delayed(const Duration(milliseconds: 50));

      isAiRespondingNotifier.state = false;
    } catch (e) {
      rethrow;
    } finally {
      isAiRespondingNotifier.state = false;
    }
  }

  Future<String> _getUIContext() async {
    final curRoute = ref.read(currentRouteProvider);
    final appRoute = AppRoutes.getAppRouteFromPath(curRoute);

    if (appRoute == null) {
      log.warning('AppRoute is null but curRoute is: $curRoute');
      return '';
    }

    final sb = StringBuffer();
    sb.writeln('CurPage: ${appRoute.toString()}\n');

    final aiContextService = ref.read(aiContextServiceProvider);

    if (appRoute == AppRoutes.taskPage) {
      final taskId = ref.read(curSelectedTaskIdNotifierProvider);
      if (taskId != null) {
        final context = await aiContextService.getTaskContext(taskId);
        if (context != null) {
          sb.writeln(context);
        }
      }
    } else if (appRoute == AppRoutes.notePage) {
      final noteId = ref.read(curSelectedNoteIdNotifierProvider);
      if (noteId != null) {
        final context = await aiContextService.getNoteContext(noteId);
        if (context != null) {
          sb.writeln(context);
        }
      }
    }

    return sb.toString();
  }

  Future<void> _runAi({
    required AiChatThreadModel aiChatThread,
    String? userMessage,
    required String uiContext,
    LgCommandModel? command,
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
      command: command,
    );

    // Convert lgBaseMessages as aiChatMessages
    final aiResponseChatMessages = lgBaseMessages
        .map((lgBaseMessage) => AiChatMessageModel(
            content: lgBaseMessage.content,
            type: AiChatMessageTypeExtension.fromLgAiChatMessageRole(
                lgBaseMessage.type),
            parentChatThreadId: aiChatThread.id))
        .toList();

    // Display ai response
    // For Groq - a tool call does not provide a message
    if (aiResponseChatMessages.isNotEmpty) {
      lastAiMessageListener.addAiChatMessage(aiResponseChatMessages.first);
      if (!isWebVersion) speakAiMessage(aiResponseChatMessages);
    }

    // Save response to DB
    await aiChatMessagesRepo.insertItems(aiResponseChatMessages);

    // Execute request if needed
    await _tryExecuteAiRequests(aiChatThread, aiResponseChatMessages);
  }

  Future<void> _tryExecuteAiRequests(AiChatThreadModel aiChatThread,
      List<AiChatMessageModel> aiChatMessages) async {
    final lastAiMessageListener =
        ref.read(lastAiMessageListenerProvider.notifier);
    final aiRequestExecutor = ref.read(aiRequestExecutorProvider);
    final aiChatMessagesRepo = ref.read(aiChatMessagesRepositoryProvider);

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

    // === Execute All Requests ===
    final allResults = StringBuffer();

    for (final toolRequest in toolResponses) {
      // Execute each request
      final result = await aiRequestExecutor.executeAiRequest(toolRequest);

      // Append result to combined results
      if (allResults.isNotEmpty) {
        allResults.write('\n\n');
      }
      allResults.write(result.resultForAi);

      // Save Result to DB
      final aiResultMessage = AiChatMessageModel(
        content: jsonEncode(result.toJson()),
        type: AiChatMessageType.tool,
        parentChatThreadId: aiChatThread.id,
        // We have to set this manually to avoid wrong ordering
        // with null values while waiting for DB to sync with supabase
        createdAt: DateTime.now().toUtc(),
      );

      await aiChatMessagesRepo.insertItem(aiResultMessage);

      // Display in UI
      lastAiMessageListener.addAiChatMessage(aiResultMessage);
    }

    // === Send All Results to LangGraph for Followup ===

    // Update the UI Context as tools may have changed it ...
    final uiContext = await _getUIContext();

    await _runAi(
        aiChatThread: aiChatThread,
        command: LgCommandModel.resume(allResults.toString()),
        uiContext: uiContext);
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

    // TODO p3 - this logic should be moved to langgraph service

    // TODO p3: get org name for assistant name
    final name = '${curUser!.email} - $curOrgId';

    // Get timezone offset string
    final timezoneOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    //final language = ref.read(languageServiceProvider).language;

    // Create new thread and assistant
    final (newLgThreadId, newLgAssistantId) =
        await langgraphService.createNewThread(
      name: name,
      lgConfig: LgConfigSchemaModel(
        timezoneOffsetMinutes: timezoneOffsetMinutes,
        //language: language,
        //orgId: orgId,
        //userId: userId,
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
