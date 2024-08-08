import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/users_read_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
//import 'package:seren_ai_flutter/services/data/tasks/tasks_read_provider.dart';

class JoinedTaskUserAssignmentsModel {
  final TaskUserAssignmentsModel assignment;
  final UserModel user;
  final TaskModel? task;

  JoinedTaskUserAssignmentsModel({
    required this.assignment,
    required this.user,
    this.task,
  });

  /*
  static Future<JoinedTaskUserAssignmentsModel> 
  fromTaskUserAssignmentsModel(
    WidgetRef ref,
    TaskUserAssignmentsModel assignmentModel,
  ) async {
    final userId = assignmentModel.userId;
    final user = await ref.read(usersReadProvider).getItem(id: userId);

    //final taskId = assignmentModel.taskId;
    //final task = await ref.read(tasksReadProvider).getItem(id: taskId);

    return JoinedTaskUserAssignmentsModel(
      assignment: assignmentModel,
      user: user,
      //task: task,
    );
  }
  */
}
