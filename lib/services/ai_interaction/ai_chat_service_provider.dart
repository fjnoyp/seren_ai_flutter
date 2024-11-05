import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/ai_request_executor.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/testing/sample_ai_chat_message_models.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_user_org_id_provider.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final isAiRespondingProvider = StateProvider<bool>((ref) => false);

final isAiEditingProvider = StateProvider<bool>((ref) => false);

final aiChatServiceProvider = Provider<AIChatService>(AIChatService.new);

class AIChatService {
  final Ref ref;

  AIChatService(this.ref);

  Future<List<AiChatMessageModel>> sendMessage(String message) async {
    ref.read(isAiRespondingProvider.notifier).state = true;

    final curOrgId = ref.read(curUserOrgIdProvider);
    final curAuthUserState = ref.read(curAuthStateProvider);

    final curUser = switch (curAuthUserState) {
      LoggedInAuthState() => curAuthUserState.user,
      _ => null,
    };

    if (curUser == null || curOrgId == null) {
      ref.read(isAiRespondingProvider.notifier).state = false;
      throw Exception('No current user or org id found');
    }

    try {
      bool isTest = false;

      List<AiChatMessageModel> aiChatMessages = [];
      if (!isTest) {
        aiChatMessages = await _sendMessage(
            message: message, userId: curUser.id, orgId: curOrgId);
      } else {
        aiChatMessages = _getTestAiChatMessages();
      }

      await executeAiChatMessages(aiChatMessages);
      await speakAiMessage(aiChatMessages);

      ref.read(isAiRespondingProvider.notifier).state = false;

      return aiChatMessages;
    } catch (e) {
      ref.read(isAiRespondingProvider.notifier).state = false;
      rethrow;
    } finally {
      ref.read(isAiRespondingProvider.notifier).state = false;
    }
  }

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

  Future<List<AiChatMessageModel>> _sendMessage(
      {required String message,
      required String userId,
      required String orgId}) async {
    try {
      print('Sending message to Supabase function...'); // Debug log
      final response = await Supabase.instance.client.functions.invoke(
        'chatv2/chat',
        method: HttpMethod.post,
        headers: {'Content-Type': 'application/json'},
        body: {'user-message': message, 'user-id': userId, 'org-id': orgId},
      );

      if (response.status != 200) {
        throw Exception(
            'Failed to send message. Status: ${response.status}, Data: ${response.data}');
      }

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data is List) {
        return AiChatMessageModel.fromJsonList(response.data as List);
      } else {
        throw Exception('Unexpected response format: ${response.data}');
      }
    } catch (e, stackTrace) {
      print('Error in _sendMessage: $e'); // Debug log
      rethrow;
    }
  }

  Future<void> executeAiChatMessages(
      List<AiChatMessageModel> aiChatMessages) async {
    // TODO p0: update last ai message provider to be manually updated by the code flow here

    // Read the chat response and identify ToolMessages
    List<AiRequestModel>? toolResponses = aiChatMessages
        .where((msg) => msg.isAiRequest())
        .expand((msg) => msg.getAiRequests() ?? List<AiRequestModel>.empty())
        .toList() as List<AiRequestModel>?;

    if (toolResponses != null && toolResponses.isNotEmpty) {
      await ref
          .read(aiRequestExecutorProvider)
          .executeAiRequests(toolResponses);
    }
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

    ref.read(curTaskProvider.notifier).updateAllFields(joinedTask);

    //test();

    // Delay setting isAiEditingProvider to false to ensure animation is triggered
    await Future.delayed(Duration(milliseconds: 500));

    ref.read(isAiEditingProvider.notifier).state = false;
  }
}
