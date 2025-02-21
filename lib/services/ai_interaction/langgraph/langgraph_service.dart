// What are the methods needed
// What methods are they calling

import 'package:seren_ai_flutter/services/ai_interaction/langgraph/langgraph_api.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_base_message_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_chat_message_role.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_config_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_input_model.dart';
import 'package:seren_ai_flutter/services/data/db_setup/app_config.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';

final langgraphServiceProvider = Provider<LanggraphService>((ref) {
  final db = ref.watch(dbProvider);
  return LanggraphService(db: db);
});

/// Interface between the app and the Langgraph API.
/// Only returns and accepts our own data types.
/// Converts to necessary Langgraph types when sending to the API.
///
/// Handles all db operations (store/retrieve) from our db.
class LanggraphService {
  late final LanggraphApi langgraphApi;
  final PowerSyncDatabase db;
  //late final LanggraphDbOperations _langgraphDbOperations;

  LanggraphService({required this.db}) {
    langgraphApi = LanggraphApi(
      apiKey: AppConfig.langgraphApiKey,
      baseUrl: AppConfig.langgraphBaseUrl,
    );
    //_langgraphDbOperations =
    //    LanggraphDbOperations(db: db, langgraphApi: langgraphApi);
  }

  /// Top level method for sending a user message to the Langgraph API AI
  Future<List<LgAiBaseMessageModel>> runAi({
    required String? message,
    required String? uiContext,
    required String lgThreadId,
    required String lgAssistantId,
  }) async {
    // Create or Get thread info stored in DB AiChatThread table
    // final aiChatThread =
    //     await _langgraphDbOperations.getOrCreateAiChatThread(userId, orgId);

    // Create input for the Langgraph API
    final lgInput = message != null
        ? LgAgentStateModel(messages: [
            LgInputMessageModel(
                role: LgAiChatMessageRole.user, content: message)
          ], uiContext: uiContext)
        : null;

    // Save user message to DB AiChatMessage table
    // await _langgraphDbOperations.saveUserAiChatMessage(
    //     userMessage, aiChatThread.id, LgAiChatMessageRole.user);

    final lgBaseMessages = await _runAi(
        lgThreadId: lgThreadId, lgAssistantId: lgAssistantId, lgInput: lgInput);

    // final aiChatMessages = await _langgraphDbOperations.saveLgBaseMessageModels(
    //   messages: lgBaseMessages,
    //   parentChatThreadId: aiChatThread.id,
    // );

    return lgBaseMessages;
  }

  Future<void> updateLastToolMessageWithResult({
    required String resultString,
    required bool showOnly,
    required String lgThreadId,
    required String lgAssistantId,
  }) async {
//     final lgAiRequestResultModel = LgAiRequestResultModel(
//         message: aiRequestResult.message, showOnly: aiRequestResult.showOnly);

// // Create or Get thread info stored in DB AiChatThread table
//     final aiChatThread =
//         await _langgraphDbOperations.getOrCreateAiChatThread(userId, orgId);

    // final showOnly = lgAiRequestResultModel.showOnly;

    // await _langgraphDbOperations.saveAiRequestResult(
    //   aiRequestResult: aiRequestResult,
    //   parentChatThreadId: aiChatThread.id,
    // );

    await updateLastToolMessageThreadState(
      lgThreadId: lgThreadId,
      resultString: resultString,
    );

    // if (!showOnly) {
    // Resume the invokation of the ai
    // final lgBaseMessages =
    //     await runAi(
    //       lgThreadId: lgThreadId,
    //       lgAssistantId: lgAssistantId,
    //       lgInput: null);

    // final aiChatMessages =
    //     await _langgraphDbOperations.saveLgBaseMessageModels(
    //   messages: lgBaseMessages,
    //   parentChatThreadId: lgThreadId,
    // );

    //   return lgBaseMessages;
    // }

    // return [];
  }

  Future<List<LgAiBaseMessageModel>> runSingleCallAi({
    required String systemMessage,
    required String userMessage,
  }) async {
    final timezoneOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;

    final lgConfig = LgConfigSchemaModel(
      timezoneOffsetMinutes: timezoneOffsetMinutes,
    );

    final assistants = await langgraphApi.searchAssistants(
      metadata: lgConfig.toJson(),
    );

    var lgAssistantId = '';
    if (assistants.isEmpty) {
      lgAssistantId = await langgraphApi.createAssistant(
        name: 'Single Call Assistant',
        lgConfig: lgConfig,
      );
    } else {
      lgAssistantId = assistants.first.assistantId;
    }

    final messages = <LgAiBaseMessageModel>[];

    await for (final message in langgraphApi.streamStatelessRun(
      assistantId: lgAssistantId,
      streamMode: 'updates',
      input: LgAgentStateModel(
        messages: [
          LgInputMessageModel(
              role: LgAiChatMessageRole.user, content: userMessage)
        ],
        aiBehaviorMode: AiBehaviorMode.singleCall,
      ),
    )) {
      messages.add(message);
    }

    return messages;
  }

  Future<List<LgAiBaseMessageModel>> _runAi({
    required String lgThreadId,
    required String lgAssistantId,
    LgAgentStateModel? lgInput,
  }) async {
    // Collect all messages from the stream
    final messages = <LgAiBaseMessageModel>[];

    // TODO p4 - we can support streaming here ...
    await for (final message in langgraphApi.streamRun(
      threadId: lgThreadId,
      assistantId: lgAssistantId,
      input: lgInput,
      streamMode: 'updates',
    )) {
      messages.add(message);
    }

    return messages;
  }

  Future<void> updateLastToolMessageThreadState({
    required String lgThreadId,
    required String resultString,
  }) async {
    final currentState = await langgraphApi.getThreadState(lgThreadId);

    final messages = currentState.messages;

    if (messages.isEmpty) {
      return;
    }

    final lastMessage = messages.last;

    // If the last message is a tool message, replace the content with the result
    if (lastMessage.type == LgAiChatMessageRole.tool) {
      await langgraphApi.addMessageToThreadState(
        lgThreadId,
        asNode: 'execute_ai_request_on_client',
        message: lastMessage.copyWithContent(resultString),
      );
    } else {
      throw Exception('Last message is not a tool message');
    }
  }

  Future<(String, String)> createNewThread({
    required String name,
    required LgConfigSchemaModel lgConfig,
  }) async {
    final newLgThreadId = await langgraphApi.createThread();

    final existingAssistants = await langgraphApi.searchAssistants(
      metadata: lgConfig.toJson(),
    );

    var newLgAssistantId = '';
    if (existingAssistants.isEmpty) {
      newLgAssistantId = await langgraphApi.createAssistant(
        name: "Default Assistant V1",
        lgConfig: lgConfig,
      );
    } else {
      newLgAssistantId = existingAssistants.first.assistantId;
    }

    return (newLgThreadId, newLgAssistantId);
  }
}
