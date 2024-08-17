// Provides the ai orchestrator for making calls to the ai services 

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final isAiEditingProvider = StateProvider<bool>((ref) => false);


final aiOrchestratorProvider = Provider<AiOrchestrator>(AiOrchestrator.new);

class AiOrchestrator {
  final Ref ref;

  AiOrchestrator(this.ref);

  Future<void> testMove(BuildContext context) async {

    ref.read(isAiEditingProvider.notifier).state = true;

    //openTaskPage(context, ref, mode: TaskPageMode.create);

    openBlankTaskPage(context, ref);

    print('openTaskPage done');

    
    await Future.delayed(Duration(milliseconds: 250));

    final joinedTask = JoinedTaskModel(
      task: TaskModel(
        name: 'AI Set Task Test',
        dueDate: DateTime.now(),
        parentProjectId: 'parentProjectId',
        parentTeamId: 'parentTeamId',
        description: 'Task description',
        statusEnum: StatusEnum.inProgress,
        createdDate: DateTime.now(),
        lastUpdatedDate: DateTime.now(),
        authorUserId: 'authorUserId',
      ),
      authorUser: UserModel(
        id: 'authorUserId',        
        email: 'ai@seren.ai',
        parentAuthUserId: 'parentAuthUserId',
      ),
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