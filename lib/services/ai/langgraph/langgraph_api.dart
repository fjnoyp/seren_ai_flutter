import 'package:dio/dio.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_ai_base_message_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_assistant_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_config_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_input_model.dart';
import 'dart:convert';
import 'dart:async';

import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_run_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_run_stream_response_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_thread_model.dart';
import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_thread_state_model.dart';

// TODO p0: create assistant with metadata to be findable again ....

/// Implementation of https://langchain-ai.github.io/langgraph/cloud/reference/api/api_ref.html
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

  Stream<LgAiBaseMessageModel> streamRun({
    required String threadId,
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
    try {
      final response = await _dio.post(
        url,
        data: requestData,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
          // Add timeout to the request
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to stream run: ${response.statusCode}',
        );
      }

      await for (final data in response.data.stream.timeout(
        timeout,
        onTimeout: (sink) {
          throw TimeoutException(
              'Stream timed out after ${timeout.inSeconds} seconds');
        },
      )) {
        try {
          final decodedData = utf8.decode(data);

          if (decodedData.trim() == ': heartbeat') {
            print('skipping heartbeat message');
            print(decodedData);
            continue;
          }

          final responseModel = LgRunStreamResponseModel.fromSSE(decodedData);

          if (responseModel.event == "updates") {
            final responseJson = json.decode(responseModel.data);

            // NOTE: In Langgraph Cloud - the name of the node added via add_node will be returned as the key here ...
            if (responseJson.containsKey("chatbot")) {
              final messagesJson = responseJson["chatbot"]["messages"];
              for (final messageJson in messagesJson) {
                yield LgAiBaseMessageModel.fromJson(messageJson);
              }
            } else if (responseJson.containsKey("tools")) {
              final messagesJson = responseJson["tools"]["messages"];
              for (final messageJson in messagesJson) {
                yield LgAiBaseMessageModel.fromJson(messageJson);
              }
            } else if (responseJson.containsKey("single_call")) {
              final messagesJson = responseJson["single_call"]["messages"];
              for (final messageJson in messagesJson) {
                yield LgAiBaseMessageModel.fromJson(messageJson);
              }
            } else {
              throw Exception('Unknown event type: ${responseJson.keys}');
            }
          }
        } catch (e) {
          yield* Stream.error(
            'Error processing stream data: $e' '\n \n $data \n\n',
            StackTrace.current,
          );
          break;
        }
      }
    } catch (e, stackTrace) {
      print('Error in stream: $e');
      yield* Stream.error(e, stackTrace);
    }
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
