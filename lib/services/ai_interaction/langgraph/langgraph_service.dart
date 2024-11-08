// What are the methods needed
// What methods are they calling

import 'package:seren_ai_flutter/services/ai_interaction/ai_request/ai_request_executor.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/langgraph_api.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/langgraph_db_operations.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_base_message_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_chat_message_role.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_input_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
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
  late final LanggraphDbOperations _langgraphDbOperations;

  LanggraphService({required this.db}) {
    langgraphApi = LanggraphApi(
      apiKey: AppConfig.langgraphApiKey,
      baseUrl: AppConfig.langgraphBaseUrl,
    );
    _langgraphDbOperations =
        LanggraphDbOperations(db: db, langgraphApi: langgraphApi);
  }

  /// Top level method for sending a user message to the Langgraph API AI
  Future<List<AiChatMessageModel>> sendUserMessage(
      String userMessage, String userId, String orgId) async {
    // Create or Get thread info stored in DB AiChatThread table
    final aiChatThread =
        await _langgraphDbOperations.getOrCreateAiChatThread(userId, orgId);

    // Create input for the Langgraph API
    final lgInput = LgInputModel(messages: [
      LgInputMessageModel(role: LgAiChatMessageRole.user, content: userMessage)
    ]);

    // Save user message to DB AiChatMessage table
    await _langgraphDbOperations.saveUserAiChatMessage(
        userMessage, aiChatThread.id, LgAiChatMessageRole.user);

    final lgBaseMessages =
        await runAi(aiChatThread: aiChatThread, lgInput: lgInput);

    final aiChatMessages = await _langgraphDbOperations.saveLgBaseMessageModels(
      messages: lgBaseMessages,
      parentChatThreadId: aiChatThread.id,
    );

    return aiChatMessages;
  }

  Future<List<AiChatMessageModel>> sendAiRequestResult(
      String userId, String orgId, AiRequestResultModel aiRequestResult) async {
    final lgAiRequestResultModel = LgAiRequestResultModel(
        message: aiRequestResult.message, showOnly: aiRequestResult.showOnly);

// Create or Get thread info stored in DB AiChatThread table
    final aiChatThread =
        await _langgraphDbOperations.getOrCreateAiChatThread(userId, orgId);

    final showOnly = lgAiRequestResultModel.showOnly;

    await _langgraphDbOperations.saveAiRequestResult(
      aiRequestResult: aiRequestResult,
      parentChatThreadId: aiChatThread.id,
    );

    await updateLastToolMessageThreadState(
      lgThreadId: aiChatThread.parentLgThreadId,
      result: lgAiRequestResultModel,
    );

    if (!showOnly) {
      // Resume the invokation of the ai
      final lgBaseMessages =
          await runAi(aiChatThread: aiChatThread, lgInput: null);

      final aiChatMessages =
          await _langgraphDbOperations.saveLgBaseMessageModels(
        messages: lgBaseMessages,
        parentChatThreadId: aiChatThread.id,
      );

      return aiChatMessages;
    }

    return [];
  }

  Future<List<LgAiBaseMessageModel>> runAi({
    required AiChatThreadModel aiChatThread,
    LgInputModel? lgInput,
  }) async {
    // Collect all messages from the stream
    final messages = <LgAiBaseMessageModel>[];

    await for (final message in langgraphApi.streamRun(
      threadId: aiChatThread.parentLgThreadId,
      assistantId: aiChatThread.parentLgAssistantId,
      input: lgInput,
      streamMode: 'updates',
    )) {
      messages.add(message);
    }

    return messages;
  }

  Future<void> updateLastToolMessageThreadState({
    required String lgThreadId,
    required LgAiRequestResultModel result,
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
        message: lastMessage.copyWithContent(result.message),
      );
    } else {
      throw Exception('Last message is not a tool message');
    }
  }
}
