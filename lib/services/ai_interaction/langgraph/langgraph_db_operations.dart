// TODO p3: consolidate SQL statements with relevant data service folder

import 'dart:convert';

import 'package:powersync/powersync.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/langgraph_api.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_base_message_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_chat_message_role.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';


// TODO p3 - for consistency - langgraph folder should have no supabase db methods, and these should instead be DI injected from the data service 
class LanggraphDbOperations {
  final PowerSyncDatabase db;
  final LanggraphApi langgraphApi;

  LanggraphDbOperations({required this.db, required this.langgraphApi});

  Future<void> saveUserAiChatMessage(
    String message,
    String parentChatThreadId,
    LgAiChatMessageRole role,
  ) async {
    await db.execute('''
      INSERT INTO ai_chat_messages (
        id,
        type,
        content,
        parent_chat_thread_id
      ) VALUES (?, ?, ?, ?)
    ''', [uuid.v4(), role.toRawString(), message, parentChatThreadId]);
  }

  // TODO: move to SQL?
  Future<AiChatThreadModel> getOrCreateAiChatThread(
      String userId, String orgId) async {
    final existingThread = await db.getAll('''
         SELECT id, author_user_id, parent_lg_thread_id, parent_org_id, parent_lg_assistant_id 
         FROM ai_chat_threads 
         WHERE author_user_id = ? 
         AND parent_org_id = ?
         LIMIT 1
       ''', [userId, orgId]);

    if (existingThread.isNotEmpty) {
      return AiChatThreadModel.fromJson(existingThread.first);
    }

    // Get org name and user email
    final orgRow =
        await db.getAll('SELECT name FROM orgs WHERE id = ? LIMIT 1', [orgId]);
    final userRow = await db
        .getAll('SELECT email FROM users WHERE id = ? LIMIT 1', [userId]);

    if (orgRow.isEmpty || userRow.isEmpty) {
      throw Exception('Could not find org or user');
    }

    final name = '${orgRow.first['name']} - ${userRow.first['email']}';

    // Create new thread and assistant
    final newLgThreadId = await langgraphApi.createThread();
    final newLgAssistantId = await langgraphApi.createAssistant(
      name: name,
      config: {
        'org_id': orgId,
        'user_id': userId,
      },
    );

    // Insert new thread record
    final newThreadRows = await db.execute('''
      INSERT INTO ai_chat_threads (
        id,
        author_user_id,
        parent_lg_thread_id,
        parent_lg_assistant_id,
        parent_org_id
      ) VALUES (?, ?, ?, ?, ?)
      RETURNING *
    ''', [uuid.v4(), userId, newLgThreadId, newLgAssistantId, orgId]);

    if (newThreadRows.isEmpty) {
      throw Exception('Failed to create new AI chat thread');
    }

    return AiChatThreadModel.fromJson(newThreadRows.first);

    // create new thread
  }

  /// When Anthropic AI calls a tool 
  /// Response content is returned as a list of JSON objects and must be parsed
  /// expected format:
  /// [
  ///   {
  ///     "type": "text",
  ///     "text": "response"
  ///   },
  ///   {
  ///     "type": "tool_use",
  ///     "name": "tool_name"
  ///   }
  /// ]
  String _parseAiMessageContent(String content) {
    try {
      final List<dynamic> parsedContent = json.decode(content);
      
      // Verify the expected format with type field
      if (!parsedContent.every((item) => item is Map && item.containsKey('type'))) {
        return content;
      }

      StringBuffer result = StringBuffer();
      for (var item in parsedContent) {
        if (item['type'] == 'text') {
          result.writeln(item['text']);
        } else if (item['type'] == 'tool_use') {
          result.writeln('Calling tool: ${item['name']}');
        }
      }

      return result.toString().trim();
    } catch (e) {
      // If parsing fails, return original content
      return content;
    }
  }

  Future<List<AiChatMessageModel>> saveLgBaseMessageModels({
    required List<LgAiBaseMessageModel> messages,
    required String parentChatThreadId,
    //required String parentLgRunId,
  }) async {
    final createdMessages = <AiChatMessageModel>[];

    for (final message in messages) {
      try {

        var content = message.content;
        if(message.type == LgAiChatMessageRole.ai) {
          content = _parseAiMessageContent(message.content);
        } 

        final messageRows = await db.execute('''
          INSERT INTO ai_chat_messages (
            id,
            type,
            content,
            parent_chat_thread_id,
            parent_lg_run_id
          ) VALUES (? , ?, ?, ?, ?)
          RETURNING *
        ''', [
          uuid.v4(),
          message.type.toRawString(),
          content,
          parentChatThreadId,
          message.id,
        ]);

        if (messageRows.isEmpty) {
          throw Exception('Failed to insert AI chat message');
        }

        createdMessages.add(AiChatMessageModel.fromJson(messageRows.first));
      } catch (e) {
        print('Failed to insert message: $e');
        rethrow;
      }
    }

    return createdMessages;
  }

  Future<void> updateLastToolMessageWithResult({
    required LgAiRequestResultModel result,
    required String parentChatThreadId,
  }) async {
    // Get the last message for this thread
    final messageRows = await db.execute('''
      SELECT * FROM ai_chat_messages 
      WHERE parent_chat_thread_id = ?
      ORDER BY created_at DESC
      LIMIT 1
    ''', [parentChatThreadId]);

    if (messageRows.isEmpty) {
      throw Exception('No messages found for thread');
    }

    final lastMessageString = messageRows.first;

    final lastMessage = LgAiBaseMessageModel.fromJson(lastMessageString);

    // Verify it's a tool message
    if (lastMessage.type== LgAiChatMessageRole.tool) {
      // Update the content with the result
      final updateRows = await db.execute('''
        UPDATE ai_chat_messages
        SET content = ?
        WHERE id = ?
        RETURNING *
      ''', [result.message, lastMessage.id]);

      if (updateRows.isEmpty) {
        throw Exception('Failed to update tool message');
      }
    } else {
      throw Exception('Last message is not a tool message');
    }
  }
}
