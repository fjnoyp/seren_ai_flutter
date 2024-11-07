import 'dart:io';

import 'package:dio/dio.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_base_message_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_assistant_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_input_model.dart';
import 'dart:convert';
import 'dart:async';

import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_run_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_run_stream_response_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_thread_state_model.dart';

// TODO p0: create assistant with metadata to be findable again ....

class LanggraphApi {
  final Dio _dio = Dio();
  final String apiKey;
  final String baseUrl;

  LanggraphApi({
    required this.apiKey,
    required this.baseUrl,
  }) {
    _dio.options.headers = {
      'Authorization': 'Bearer $apiKey',
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
    Map<String, dynamic>? config,
    Map<String, dynamic>? metadata,
    String ifExists = "raise",
  }) async {
    final response = await _dio.post(
      '$baseUrl/assistants',
      data: {
        'name': name,
        'graph_id': graphId,
        'config': config ?? {},
        'metadata': metadata ?? {},
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

  Stream<LgAiBaseMessageModel> streamRun({
    required String threadId,
    required String assistantId, 
    required String streamMode,
    LgInputModel? input,
    Duration timeout = const Duration(minutes: 5),
  }) async* {
    final requestData = {
      'assistant_id': assistantId,
      'stream_mode': streamMode,
      'input': input?.toJson(),
    };

    try {
      final response = await _dio.post(
        '$baseUrl/threads/$threadId/runs/stream',
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
          final responseModel = LgRunStreamResponseModel.fromSSE(decodedData);

          if (responseModel.event == "updates") {
            final responseJson = json.decode(responseModel.data);

            if (responseJson.containsKey("chatbot")) {
              // this is a list of messages
              final messagesJson = responseJson["chatbot"]["messages"];

              for (final messageJson in messagesJson) {
                yield LgAiBaseMessageModel.fromJson(messageJson);
              }
            }
            else if (responseJson.containsKey("tools")) {
              // tools.messages

              final messagesJson = responseJson["tools"]["messages"];

              for (final messageJson in messagesJson) {
                yield LgAiBaseMessageModel.fromJson(messageJson);
              }
            } else {
              throw Exception('Unknown event type: ${responseJson.keys}');
            }
          }
        } catch (e) {
          // Instead of just printing and continuing, we propagate the error
          yield* Stream.error(
            'Error processing stream data: $e',
            StackTrace.current,
          );
          break; // Exit the stream after error
        }
      }
    } catch (e, stackTrace) {
      print('Error in streamRun: $e');
      yield* Stream.error(e, stackTrace);
    }
  }

  Future<LgThreadStateModel> getThreadState(String threadId) async {
    final response = await _dio.get(
      '$baseUrl/threads/$threadId/state',
    );
    return LgThreadStateModel.fromJson(response.data);
  }

  Future<void> updateThreadState(
    String threadId, {
    String? asNode,
    required LgThreadStateModel state,
  }) async {
    await _dio.put(
      '$baseUrl/threads/$threadId/state',
      data: {
        if (asNode != null) 'as_node': asNode,
        ...state.toJson(),
      },
    );
  }

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
}










