// Provides the ai orchestrator for making calls to the ai services 

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/ai_chat_messages_db_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/cur_chat_thread_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final isAiEditingProvider = StateProvider<bool>((ref) => false);


final aiOrchestratorProvider = Provider<AiOrchestrator>(AiOrchestrator.new);

class AiOrchestrator {
  final Ref ref;

  AiOrchestrator(this.ref);

  Future<void> testChatMessage({required String message}) async {

    final curChatThread = ref.watch(curChatThreadProvider);

    if (curChatThread == null) {
      print('No chat thread found');
      return;
    }

    final threadId = curChatThread.id;

   // create a chat message in the threadId
   final chatMessage = AiChatMessageModel(
     type: AiChatMessageType.user,
     createdAt: DateTime.now().toUtc(),
     content: message,
     parentChatThreadId: threadId,
   );

   final aiChatMessagesDb = await ref.read(aiChatMessagesDbProvider);

   await aiChatMessagesDb.insertItem(chatMessage);

   // generate ai response 


    final supabase = Supabase.instance.client;
    final res = await supabase.functions.invoke(
      'chat', 
      body: {
        'userMessage': message,
        'threadId': threadId,
      });

    if (res.status != 200) {
      print('Error: ${res.status}');
    } else {
      print('Response: ${res.data}');
    }

    // TODO p1: add ai response to the thread 




  /*
   final aiChatMessage = AiChatMessageModel(
     type: AiChatMessageType.ai,
     createdAt: DateTime.now().toUtc(),
     content: res.data,
     parentChatThreadId: threadId,
   );

   await aiChatMessagesDb.insertItem(aiChatMessage);
   */

   // update the thread with the ai response 

  }

  Future<void> testMove(BuildContext context) async {

    // TEST calling Supabase Edge Function 
    final supabase = Supabase.instance.client;

    /*
    final res = await supabase.functions.invoke('chat', body: {'input': 'Your input message here'});

    if (res.status != 200) {
      print('Error: ${res.status}');
    } else {
      print('Response: ${res.data}');
    }
    */

    



    ref.read(isAiEditingProvider.notifier).state = true;

    //openTaskPage(context, ref, mode: TaskPageMode.create);

    openBlankTaskPage(context, ref);

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
  
  void test() {

    // TODO: how to do screen navigation? 




    // TODO: how to animate/highlight the taskName change 
    //ref.read(curTaskProvider.notifier).updateTaskName('AI Set Task Test');

    print('test');
  }
}