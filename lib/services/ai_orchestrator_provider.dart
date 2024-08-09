// Provides the ai orchestrator for making calls to the ai services 

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';

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

    // wait for 2 seconds since openTaskPage clears the task data 
    await Future.delayed(Duration(milliseconds: 250));
    ref.read(curTaskProvider.notifier).updateTaskName('AI Set Task Test');

        


    test(); 

    // Delay setting isAiEditingProvider to false to ensure animation is triggered
    await Future.delayed(Duration(milliseconds: 500));

    ref.read(isAiEditingProvider.notifier).state = false;

  }
  
  void test() {

    // TODO: how to do screen navigation? 




    // TODO: how to animate/highlight the taskName change 
    ref.read(curTaskProvider.notifier).updateTaskName('AI Set Task Test');

    print('test');
  }
}