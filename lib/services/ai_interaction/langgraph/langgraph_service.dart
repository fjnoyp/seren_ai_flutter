// What are the methods needed
// What methods are they calling

import 'package:seren_ai_flutter/services/ai_interaction/langgraph/langgraph_api.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/langgraph_db_operations.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_base_message_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_chat_message_role.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_input_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_thread_state_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/data/db_setup/app_config.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';

final langgraphServiceProvider = Provider<LanggraphService>((ref) {
  final db = ref.watch(dbProvider);
  return LanggraphService(db: db);
});

class LanggraphService {
  late final LanggraphApi _langgraphApi;
  final PowerSyncDatabase db;
  late final LanggraphDbOperations langgraphDbOperations;

  LanggraphService({required this.db}) {
    _langgraphApi = LanggraphApi(
      apiKey: AppConfig.langgraphApiKey,
      baseUrl: AppConfig.langgraphBaseUrl,
    );
    langgraphDbOperations =
        LanggraphDbOperations(db: db, langgraphApi: _langgraphApi);
  }

  /// Top level method for sending a user message to the Langgraph API AI
  Future<List<LgAiBaseMessageModel>> sendUserMessage(
      String userMessage, String userId, String orgId) async {
    // Create or Get thread info stored in DB AiChatThread table
    final aiChatThread =
        await langgraphDbOperations.getOrCreateAiChatThread(userId, orgId);

    // Create input for the Langgraph API
    final lgInput = LgInputModel(messages: [
      LgInputMessageModel(role: LgAiChatMessageRole.user, content: userMessage)
    ]);

    // Save user message to DB AiChatMessage table
    await langgraphDbOperations.saveUserAiChatMessage(
        userMessage, aiChatThread.id, LgAiChatMessageRole.user);

    final messages = await runAi(aiChatThread: aiChatThread, lgInput: lgInput);

    await langgraphDbOperations.saveLgBaseMessageModels(
      messages: messages,
      parentChatThreadId: aiChatThread.id,
    );

    return messages;
  }

  Future<List<LgAiBaseMessageModel>> sendAiRequestResult(
      String userMessage,
      String userId,
      String orgId,
      LgAiRequestResultModel lgAiRequestResultModel) async {
// Create or Get thread info stored in DB AiChatThread table
    final aiChatThread =
        await langgraphDbOperations.getOrCreateAiChatThread(userId, orgId);

    final showOnly = lgAiRequestResultModel.showOnly;

    await langgraphDbOperations.updateLastToolMessageWithResult(
      result: lgAiRequestResultModel,
      parentChatThreadId: aiChatThread.id,
    );

    if (!showOnly) {
      // Resume the invokation of the ai
      final messages = await runAi(aiChatThread: aiChatThread, lgInput: null);

      await langgraphDbOperations.saveLgBaseMessageModels(
        messages: messages,
        parentChatThreadId: aiChatThread.id,
      );

      return messages;
    }

    return [];
  }

  Future<List<LgAiBaseMessageModel>> runAi({
    required AiChatThreadModel aiChatThread,
    LgInputModel? lgInput,
  }) async {
    // Collect all messages from the stream
    final messages = <LgAiBaseMessageModel>[];

    await for (final message in _langgraphApi.streamRun(
      threadId: aiChatThread.parentLgThreadId,
      assistantId: aiChatThread.parentLgAssistantId,
      input: lgInput,
      streamMode: 'updates',
    )) {
      messages.add(message);
    }

    return messages;
  }

  Future<void> updateLastToolMessageWithResult({
    required String lgThreadId,
    required LgAiRequestResultModel result,
  }) async {
    final currentState = await _langgraphApi.getThreadState(lgThreadId);

    final messages = currentState.messages;

    if (messages.isEmpty) {
      return;
    }

    final lastMessage = messages.last;

    // If the last message is a tool message, replace the content with the result
    if (lastMessage.type == LgAiChatMessageRole.tool) {
      // Create updated state with modified message
      final updatedState = LgThreadStateModel(
        messages: [
          ...messages.take(messages.length - 1),
          LgAiBaseMessageModel(
            messageContent: result.message,
            messageType: lastMessage.type.toString(),
            id: lastMessage.id,
          )
        ],
        otherValues: currentState.otherValues,
      );

      await _langgraphApi.updateThreadState(
        lgThreadId,
        asNode: 'execute_ai_request_on_client',
        state: updatedState,
      );
    }
  }
}
