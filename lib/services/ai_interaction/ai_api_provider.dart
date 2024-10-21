// Provides the ai orchestrator for making calls to the ai services

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/ai_chat_messages_db_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/ai_chat_threads_db_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/cur_chat_thread_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_org_id_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final isAiRespondingProvider = StateProvider<bool>((ref) => false);

final isAiEditingProvider = StateProvider<bool>((ref) => false);

final aiApiProvider = Provider<AiApi>(AiApi.new);

class AiApi {
  final Ref ref;

  AiApi(this.ref);

  Future<AiChatThreadModel?> createChatThreadIfNone() async {
    final curAuthUserState = ref.read(curAuthStateProvider);
    final curUser = switch (curAuthUserState) {
      LoggedInAuthState() => curAuthUserState.user,
      _ => null,
    };

    final chatThreadDb = ref.read(aiChatThreadsDbProvider);
    final chatThreads = await chatThreadDb.getItems(eqFilters: [
      {
        'key': 'author_user_id',
        'value': curUser?.id,
      },
    ]);

    if (chatThreads.isEmpty) {
      // Create one if necessary
      print('No chat thread found, creating one');

      final curAuthUserId = curUser?.id;
      final curOrgId = ref.read(curOrgIdProvider);

      if (curAuthUserId == null || curOrgId == null) {
        print('No current user or org id found');
        throw Exception('No current user or org id found');
      }

      final newChatThread = AiChatThreadModel(
          authorUserId: curAuthUserId,
          name: 'Default Chat Thread',
          parentOrgId: curOrgId);
      await chatThreadDb.insertItem(newChatThread);

      return newChatThread;
    }

    return chatThreads[0];
  }

  Future<void> sendMessageToAi({required String message}) async {
    //return testHardcodedAiResponse(message: message);

    var curChatThread = ref.watch(curChatThreadProvider);

    curChatThread ??= await createChatThreadIfNone();

    if (curChatThread == null) {
      print('No chat thread found');
      return;
    }

    ref.read(isAiRespondingProvider.notifier).state = true;

    final threadId = curChatThread.id;

    /*

curl -X POST https://***REMOVED***.supabase.co/functions/v1/chat \
-H "Authorization: Bearer YOUR_SUPABASE_API_KEY" \
-H "Content-Type: application/json" \
-d '{
  "userMessage": "Hello, AI!",
  "threadId": "73fc85bd-b529-40b3-8732-100d4e9c5157"
}'

curl -L -X POST 'https://***REMOVED***.supabase.co/functions/v1/chat' -H 'Authorization: Bearer ***REMOVED***.XNAuj7T-RICJnA2bD3gmSB7OnUx43CwkRZ75iveBfUA' --data '{"name":"Functions"}'
    */

    final supabase = Supabase.instance.client;
    final res = await supabase.functions.invoke('chat', body: {
      'userMessage': message,
      'threadId': threadId,
    });

    if (res.status != 200) {
      print('Error: ${res.status}');
    } else {
      print('Response: ${res.data}');
    }

    ref.read(isAiRespondingProvider.notifier).state = false;

    // TODO p1: confirm if backend updates the thread with the ai response ..
    /*
    final aiChatMessage = AiChatMessageModel(
      type: AiChatMessageType.ai,
      createdAt: DateTime.now().toUtc(),
      content: res.data,
      parentChatThreadId: threadId,
    );
    await aiChatMessagesDb.insertItem(aiChatMessage);
    */
  }

  // Test calling ai and receiving a hardcoded response
  Future<void> testHardcodedAiResponse({required String message}) async {
    // Manually update the chat thread
    final curChatThread = ref.watch(curChatThreadProvider);

    if (curChatThread == null) {
      print('No chat thread found');
      return;
    }

    final aiChatMessagesDb = ref.read(aiChatMessagesDbProvider);

    final userChatMessage = AiChatMessageModel(
      type: AiChatMessageType.user,
      createdAt: DateTime.now().toUtc(),
      content: message,
      parentChatThreadId: curChatThread.id,
    );
    await aiChatMessagesDb.insertItem(userChatMessage);

    final aiChatMessage = AiChatMessageModel(
      type: AiChatMessageType.ai,
      createdAt: DateTime.now().toUtc(),
      content: "I'm responding to your message: $message",
      parentChatThreadId: curChatThread.id,
    );
    await aiChatMessagesDb.insertItem(aiChatMessage);
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
        parentTeamId: 'parentTeamId',
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
        parentTeamId: 'parentTeamId',
      ),
      team: TeamModel(
        id: 'teamId',
        name: 'TEST',
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
