import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_ai_base_message_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_assistant_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_config_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_agent_state_model.dart';
import 'dart:convert';
import 'dart:async';

import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_run_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_thread_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_thread_state_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_command_model.dart';

/// Implementation of https://langchain-ai.github.io/langgraph/cloud/reference/api/api_ref.html
///
final log = Logger('LanggraphApi');

class LanggraphApi {
  final Dio _dio = Dio();
  final String apiKey;
  final String baseUrl;

  LanggraphApi({
    required this.apiKey,
    required this.baseUrl,
  }) {
    _dio.options.headers = {
      //'Authorization': 'Bearer $apiKey',
      'X-Api-Key': apiKey,
      'Content-Type': 'application/json',
    };
  }

  // Create a new thread
  Future<String> createThread() async {
    final response = await _dio.post(
      '$baseUrl/threads',
      data: {},
    );
    return response.data['thread_id'];
  }

  Future<String> createAssistant({
    required String name,
    String graphId = "agent", // set from langgraph config
    required LgConfigSchemaModel lgConfig,
    String ifExists = "raise",
  }) async {
    final config = {
      'configurable': lgConfig.toJson(),
    };

    final response = await _dio.post(
      '$baseUrl/assistants',
      data: {
        'name': name,
        'graph_id': graphId,
        'config': config,
        'metadata': lgConfig.toJson(),
        'if_exists': ifExists,
      },
    );
    return response.data['assistant_id'];
  }

  Future<List<LgRunModel>> getThreadRuns(String threadId) async {
    final response = await _dio.get(
      '$baseUrl/threads/$threadId/runs',
    );
    return (response.data as List)
        .map((run) => LgRunModel.fromJson(run as Map<String, dynamic>))
        .toList();
  }

  Stream<LgAiBaseMessageModel> streamStatelessRun({
    required String assistantId,
    required String streamMode,
    LgAgentStateModel? input,
    Duration timeout = const Duration(minutes: 5),
  }) async* {
    final requestData = {
      'assistant_id': assistantId,
      'stream_mode': streamMode,
      'input': input?.toJson(),
    };

    yield* _handleStreamResponse(
      '$baseUrl/runs/stream',
      requestData,
      timeout,
    );
  }

  // TODO p3: streaming is not worked ...
  // https://langchain-ai.github.io/langgraph/cloud/reference/api/api_ref.html#tag/thread-runs/POST/threads/{thread_id}/runs/stream
  Stream<LgAiBaseMessageModel> streamRun({
    required String threadId,
    required String assistantId,
    String streamMode = 'updates',
    LgAgentStateModel? input,
    LgCommandModel? command,
    Duration timeout = const Duration(minutes: 5),
  }) async* {
    final requestData = {
      'assistant_id': assistantId,
      'stream_mode': streamMode,
      if (input != null) 'input': input.toJson(),
      if (command != null) 'command': command.toJson(),
    };

    yield* _handleStreamResponse(
      '$baseUrl/threads/$threadId/runs/stream',
      requestData,
      timeout,
    );
  }

  Stream<LgAiBaseMessageModel> _handleStreamResponse(
    String url,
    Map<String, dynamic> requestData,
    Duration timeout,
  ) async* {
    log.info('Starting stream request to: $url');
    try {
      // Modify options for web to handle streams better
      final options = Options(
        responseType: ResponseType.stream,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
        },
        validateStatus: (status) => status! < 500,
        // Don't use sendTimeout on web platforms as it's not supported without a request body
        sendTimeout: kIsWeb ? null : timeout,
        receiveTimeout: timeout,
        extra: kIsWeb ? {'Accept-Encoding': 'identity'} : {},
      );

      final response = await _dio.post(
        url,
        data: requestData,
        options: options,
      );

      if (response.statusCode != 200) {
        log.severe('Non-200 status code: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to stream run: ${response.statusCode}',
        );
      }

      var messageCount = 0;
      log.fine('Starting stream processing');

      await for (final data in response.data.stream.timeout(
        timeout,
        onTimeout: (sink) {
          log.severe('Stream timed out after ${timeout.inSeconds} seconds');
          throw TimeoutException(
              'Stream timed out after ${timeout.inSeconds} seconds');
        },
      )) {
        try {
          // Process the chunk
          messageCount++;

          // Decode the chunk data
          final decodedData = utf8.decode(data);

          if (decodedData.trim() == ': heartbeat') {
            continue;
          }

          // Split the data into individual SSE events
          // SSE events are separated by double newlines
          final sseEvents = _splitSseEvents(decodedData);

          // Process each SSE event
          for (int i = 0; i < sseEvents.length; i++) {
            final sseEvent = sseEvents[i];
            if (sseEvent.trim().isEmpty) continue;

            try {
              // Extract event type and data
              final eventType = _extractEventType(sseEvent);
              final eventData = _extractEventData(sseEvent);

              if (eventType == null || eventData == null) {
                log.warning('Invalid SSE event format, skipping');
                continue;
              }

              // Process "updates" events, which contain the data we're interested in
              if (eventType == "updates") {
                try {
                  final responseJson = json.decode(eventData);

                  // Handle different node types
                  const keys = [
                    "chatbot",
                    "response_generator",
                    "tools",
                    "single_call"
                  ];
                  bool keyFound = false;

                  for (final key in keys) {
                    if (responseJson.containsKey(key)) {
                      keyFound = true;

                      // Make sure this section has messages
                      if (!responseJson[key].containsKey("messages")) {
                        log.warning('$key node has no messages field');
                        continue;
                      }

                      final messagesJson = responseJson[key]["messages"];

                      for (final messageJson in messagesJson) {
                        yield LgAiBaseMessageModel.fromJson(messageJson);
                      }
                      break;
                    }
                  }

                  // Also check for thinking keys
                  const thinkingKeys = [
                    "planner",
                    "tool_caller",
                    "execute_ai_request_on_client"
                  ];
                  for (final key in thinkingKeys) {
                    if (responseJson.containsKey(key)) {
                      keyFound = true;
                      // No messages to yield from thinking nodes
                      break;
                    }
                  }

                  if (!keyFound && !responseJson.containsKey("__interrupt__")) {
                    log.warning(
                        'Unknown event keys: ${responseJson.keys.join(', ')}');
                  }
                } catch (jsonError) {
                  log.severe('JSON parsing error: $jsonError');
                  log.severe('Event data causing error: $eventData');
                }
              }
            } catch (parseError) {
              log.warning('Error parsing SSE event: $parseError');
              // Continue to the next event rather than failing the entire stream
              continue;
            }
          }
        } catch (e) {
          log.severe('Error processing stream data: $e', e, StackTrace.current);
          yield* Stream.error(
              'Error processing stream data: $e', StackTrace.current);
          break;
        }
      }

      log.info('Stream completed, processed $messageCount chunks');
    } catch (e, stackTrace) {
      log.severe('Error in stream: $e', e, stackTrace);
      yield* Stream.error(e, stackTrace);
    }
  }

  // Helper method to split a chunk into individual SSE events
  List<String> _splitSseEvents(String chunk) {
    // Try different delimiters to handle platform differences
    if (chunk.contains('\r\n\r\n')) {
      return chunk.split('\r\n\r\n').where((e) => e.trim().isNotEmpty).toList();
    } else if (chunk.contains('\n\n')) {
      return chunk.split('\n\n').where((e) => e.trim().isNotEmpty).toList();
    } else {
      // If no standard delimiter is found, try to be more flexible
      final events = RegExp(r'event:.*?data:.*?(?=event:|$)', dotAll: true)
          .allMatches(chunk)
          .map((m) => m.group(0)!)
          .toList();

      if (events.isEmpty) {
        log.warning('Could not split events using regex');
        // Fall back to treating the whole chunk as one event
        return [chunk];
      }

      return events;
    }
  }

  // Extract the event type from an SSE event
  String? _extractEventType(String sseEvent) {
    final match = RegExp(r'event:\s*([^\r\n]+)').firstMatch(sseEvent);
    return match?.group(1)?.trim();
  }

  // Extract the data portion from an SSE event
  String? _extractEventData(String sseEvent) {
    final match = RegExp(r'data:\s*(.+)', dotAll: true).firstMatch(sseEvent);
    return match?.group(1)?.trim();
  }

  Future<LgThreadStateModel> getThreadState(String threadId) async {
    final response = await _dio.get(
      '$baseUrl/threads/$threadId/state',
    );
    return LgThreadStateModel.fromJson(response.data);
  }

  Future<void> addMessageToThreadState(
    String threadId, {
    String? asNode,
    required LgAiBaseMessageModel message,
  }) async {
    try {
      final requestData = {
        "as_node": "execute_ai_request_on_client",
        "values": {
          "messages": [
            message.toJson(),
          ]
        }
      };

      final response = await _dio.post('$baseUrl/threads/$threadId/state',
          data: requestData,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ));

      if (response.statusCode != 200) {
        throw Exception('Failed to update thread state: ${response.data}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /*
curl --request POST \
  --url http://localhost:8123/threads/c55a9029-ef0b-4160-b0d5-bce5e0930be2/state \
  --header 'Content-Type: application/json' \
  --data '{
  "as_node": "execute_ai_request_on_client",
  "values": {    
    "messages": [
      {
        "content": "this is a human message",
        "type": "human"
      }
    ] 
  }
}'
*/

  Future<List<LgAssistantModel>> searchAssistants({
    Map<String, dynamic>? metadata,
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await _dio.post(
      '$baseUrl/assistants/search',
      data: {
        'metadata': metadata ?? {},
        'limit': limit,
        'offset': offset,
      },
    );

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((assistant) =>
              LgAssistantModel.fromJson(assistant as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to search assistants: ${response.data}');
    }
  }

  Future<List<LgThreadModel>> searchThreads({
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? values,
    String? status = "idle",
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await _dio.post(
      '$baseUrl/threads/search',
      data: {
        if (metadata != null) 'metadata': metadata,
        if (values != null) 'values': values,
        'status': status,
        'limit': limit,
        'offset': offset,
      },
    );

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((thread) =>
              LgThreadModel.fromJson(thread as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to search threads: ${response.data}');
    }
  }

  Future<void> deleteAssistant(String assistantId) async {
    final response = await _dio.delete(
      '$baseUrl/assistants/$assistantId',
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete assistant: ${response.data}');
    }
  }

  Future<void> deleteThread(String threadId) async {
    final response = await _dio.delete(
      '$baseUrl/threads/$threadId',
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete thread: ${response.data}');
    }
  }
}
