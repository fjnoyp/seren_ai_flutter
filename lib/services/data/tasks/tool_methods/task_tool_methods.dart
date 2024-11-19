/*
Method executors for: 

AiInfoRequestType.findTasks

AiActionRequestType.createTask
AiActionRequestType.updateTaskFields
AiActionRequestType.deleteTask
AiActionRequestType.assignUserToTask
*/
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/utils/date_time_extension.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/error_request_result_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/date_list_parser.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/utils/string_similarity_extension.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_service_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/joined_task_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/tasks_db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/create_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/delete_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/find_tasks_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/task_request_models.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/update_task_fields_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/edit_task_button.dart';

class TaskToolMethods {
  // Threshold for string similarity (0.0 to 1.0)
  static const double _similarityThreshold = 0.6;
  static const double _differenceThreshold = 0.8;

  // TODO p2: switch to pagination + db based FTS + semantic search
  Future<AiRequestResultModel> findTasks(
      {required Ref ref, required FindTasksRequestModel infoRequest}) async {
    final userId = _getUserId(ref);
    if (userId == null) return _handleNoAuth();

    final joinedTasks = await ref
        .read(joinedTasksRepositoryProvider)
        .getUserViewableJoinedTasks(userId);

    // Get a list of dates to allow for due date search
    final List<DateTime> dueDatesToGet = infoRequest.dueDatesToGet != null
        ? DateListParser.parseDateList(infoRequest.dueDatesToGet!)
        : [];
    final List<DateTime> createdDatesToGet =
        infoRequest.createdDatesToGet != null
            ? DateListParser.parseDateList(infoRequest.createdDatesToGet!)
            : [];

    // Filter tasks based on search criteria
    final filteredTasks = joinedTasks.where((joinedTask) {
      final task = joinedTask.task;
      final project = joinedTask.project;
      final author = joinedTask.authorUser;

      // Name search with fuzzy matching
      if (infoRequest.taskName != null &&
          task.name.similarity(infoRequest.taskName!) < _similarityThreshold) {
        return false;
      }

      // Description search with fuzzy matching
      if (infoRequest.taskDescription != null &&
          task.description != null &&
          task.description!.similarity(infoRequest.taskDescription!) <
              _similarityThreshold) {
        return false;
      }

      // Project name search with fuzzy matching
      if (infoRequest.parentProjectName != null &&
          project != null &&
          project.name.similarity(infoRequest.parentProjectName!) <
              _similarityThreshold) {
        return false;
      }

      // Author email / username search with fuzzy matching
      if (infoRequest.authorUserName != null &&
          author != null &&
          author.email.similarity(infoRequest.authorUserName!) <
              _similarityThreshold) {
        return false;
      }

      // Keep exact matching for non-string fields
      if (infoRequest.taskStatus != null &&
          task.status != null &&
          task.status!.name.toLowerCase() !=
              infoRequest.taskStatus!.toLowerCase()) {
        return false;
      }

      // Status match
      if (infoRequest.taskStatus != null &&
          task.status != null &&
          task.status!.name.toLowerCase() !=
              infoRequest.taskStatus!.toLowerCase()) {
        return false;
      }

      // Priority match
      if (infoRequest.taskPriority != null &&
          task.priority != null &&
          task.priority!.name.toLowerCase() !=
              infoRequest.taskPriority!.toLowerCase()) {
        return false;
      }

      // Check overdue tasks
      if (infoRequest.getOverdueTasksOnly != null &&
          infoRequest.getOverdueTasksOnly!) {
        if (task.dueDate == null ||
            task.dueDate!.isAfter(DateTime.now().toUtc())) {
          return false;
        }
      }

      // Due date search
      final dueDate = task.dueDate;
      if (dueDatesToGet.isNotEmpty && dueDate != null) {
        if (!dueDatesToGet.any((dateToGet) => dueDate.isSameDate(dateToGet))) {
          return false;
        }
      }

      // Created date search
      final createdDate = task.createdAt;
      if (createdDatesToGet.isNotEmpty && createdDate != null) {
        if (!createdDatesToGet.any((dateToGet) => createdDate.isSameDate(dateToGet))) {
          return false;
        }
      }

      // Duration estimate match
      if (infoRequest.estimateDurationMinutes != null &&
          task.estimatedDurationMinutes != null &&
          (task.estimatedDurationMinutes! <
                  infoRequest.estimateDurationMinutes! * 0.5 ||
              task.estimatedDurationMinutes! >
                  infoRequest.estimateDurationMinutes! * 1.5)) {
        return false;
      }

      // Assigned users match using similarity calculation
      if (infoRequest.assignedUserNames != null &&
          infoRequest.assignedUserNames!.isNotEmpty) {
        final taskAssigneeNames =
            joinedTask.assignees.map((u) => u.email.toLowerCase()).toList();
        final searchNames =
            infoRequest.assignedUserNames!.map((n) => n.toLowerCase()).toList();

        // Calculate similarity and check if any search name matches task assignee names
        if (!searchNames.any((searchName) => taskAssigneeNames.any((taskName) =>
            searchName.similarity(taskName) > _differenceThreshold))) {
          return false;
        }
      }

      return true;
    }).toList();

    return FindTasksResultModel(
      tasks: filteredTasks,
      resultForAi:
          'Found ${filteredTasks.length} matching tasks: ${filteredTasks.map((task) => task.toReadableMap()).toList()}',
      showOnly: infoRequest.showOnly,
    );
  }

  Future<AiRequestResultModel> createTask(
      {required Ref ref,
      required CreateTaskRequestModel actionRequest,
      required bool allowToolUiActions}) async {
    final userId = _getUserId(ref);
    if (userId == null) return _handleNoAuth();

    // Create a new task with fields from the request
    final task = TaskModel(
      name: actionRequest.taskName,
      description: actionRequest.taskDescription,
      dueDate: actionRequest.taskDueDate != null
          ? DateTime.parse(actionRequest.taskDueDate!)
          : null,
      status: StatusEnum.open,
      priority: actionRequest.taskPriority != null
          ? PriorityEnum.values
              .byName(actionRequest.taskPriority!.toLowerCase())
          : null,
      estimatedDurationMinutes: actionRequest.estimateDurationMinutes,
      authorUserId: userId,
      // TODO: add `actionRequest.parentProjectId` instead of always using defaultProjectId
      parentProjectId: ref.read(curUserProvider).value!.defaultProjectId ?? '',
    );

    // Save the task in the current task service
    await ref.read(tasksDbProvider).upsertItem(task);

    log('Created new task "${task.name}"');

    final savedJoinedTask = await ref
        .read(joinedTasksRepositoryProvider)
        .getJoinedTaskById(task.id);

    // Navigate to task page in readOnly mode
    if (allowToolUiActions) {
      ref.read(curTaskServiceProvider).loadTask(savedJoinedTask!);

      final navigationService = ref.read(navigationServiceProvider);
      navigationService.navigateTo(AppRoutes.taskPage.name, arguments: {
        'mode': EditablePageMode.readOnly,
        'actions': [const EditTaskButton()],
      });

      log('and opened task page');
    } else {
      log('but UI actions are not allowed');
    }

    return CreateTaskResultModel(
      joinedTask: savedJoinedTask!,
      resultForAi: allowToolUiActions
          ? 'Created new task "${task.name}" and opened task page'
          : 'Created new task "${task.name}", but UI actions are not allowed',
      showOnly: true,
    );
  }

  // TODO p2: move this to a db method
  Future<List<JoinedTaskModel>> _getJoinedTasksByName(
      Ref ref, String searchTaskName) async {
    final userId = _getUserId(ref);
    if (userId == null) return [];

    final joinedTasks = await ref
        .read(joinedTasksRepositoryProvider)
        .getUserViewableJoinedTasks(userId);

    // Calculate similarity scores and sort
    final tasksWithScores = joinedTasks
        .map((joinedTask) {
          final similarity = joinedTask.task.name.similarity(searchTaskName);
          return (joinedTask, similarity);
        })
        .where((tuple) => tuple.$2 >= _similarityThreshold)
        .toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));

    // Return top 3 matches
    return tasksWithScores.take(3).map((tuple) => tuple.$1).toList();
  }

  Future<AiRequestResultModel> updateTaskFields(
      {required Ref ref,
      required UpdateTaskFieldsRequestModel actionRequest,
      required bool allowToolUiActions}) async {
    final matchingTasks =
        await _getJoinedTasksByName(ref, actionRequest.taskName);

    // TODO p2: determine task matching logic - may want to ask user for confirmation or add a good undo
    // For now - just update the first matching task
    final joinedTask = matchingTasks.first;
    final taskToModify = joinedTask.task;

    final updatedTask = taskToModify.copyWith(
      name: actionRequest.taskName,
      description: actionRequest.taskDescription,
      dueDate: actionRequest.taskDueDate != null
          ? DateTime.parse(actionRequest.taskDueDate!)
          : null,
      status: actionRequest.taskStatus != null
          ? StatusEnum.values.byName(actionRequest.taskStatus!.toLowerCase())
          : null,
      priority: actionRequest.taskPriority != null
          ? PriorityEnum.values
              .byName(actionRequest.taskPriority!.toLowerCase())
          : null,
      estimatedDurationMinutes: actionRequest.estimateDurationMinutes,
      updatedAt: DateTime.now().toUtc(),
    );

    // Show the new task fields and ask for confirmation

    final updatedJoinedTask = joinedTask.copyWith(task: updatedTask);

    if (allowToolUiActions) {
      ref.read(curTaskServiceProvider).loadTask(updatedJoinedTask);
    }

    return UpdateTaskFieldsResultModel(
      joinedTask: updatedJoinedTask,
      resultForAi: 'Updated task "${updatedTask.name}" and showed result in UI',
      showOnly: true,
    );

    // 1) get the task name
    // 2) make sure it's open and currently viewed
    // 3) update the task fields
    // 4) return the updated task fields (TBD)

    // return ErrorRequestResultModel(
    //     resultForAi: 'Not implemented for request: ${actionRequest.toString()}',
    //     showOnly: true);
  }

  Future<AiRequestResultModel> deleteTask(
      {required Ref ref, required DeleteTaskRequestModel actionRequest}) async {
    final userId = _getUserId(ref);
    if (userId == null) return _handleNoAuth();

    final joinedTasks = await ref
        .read(tasksRepositoryProvider)
        .getUserViewableTasks(userId: userId);

    final filteredTasks = joinedTasks.where((task) =>
        task.name.similarity(actionRequest.taskName) >= _similarityThreshold);

    if (filteredTasks.isEmpty) {
      return ErrorRequestResultModel(
          resultForAi: 'Task not found', showOnly: true);
    } else if (filteredTasks.length > 1) {
      // TODO: handle this case
      return ErrorRequestResultModel(
        resultForAi:
            'Multiple tasks found with name "${actionRequest.taskName}"',
        showOnly: true,
      );
    }

    // If the task is found, move on to deleting it
    final joinedTask = await ref
        .read(joinedTasksRepositoryProvider)
        .getJoinedTaskById(filteredTasks.first.id);
    final taskService = ref.read(curTaskServiceProvider);
    taskService.loadTask(joinedTask!);

    final navigationService = ref.read(navigationServiceProvider);
    final deleted = await navigationService.showPopupDialog(
      DeleteConfirmationDialog(
        itemName: joinedTask.task.name,
        onDelete: () async {
          await ref.read(tasksDbProvider).deleteItem(joinedTask.task.id);
        },
      ),
    );

    return DeleteTaskResultModel(
      resultForAi: deleted == true
          ? 'Successfully deleted task "${joinedTask.task.name}"'
          : 'Task deletion cancelled by user for "${joinedTask.task.name}"',
      showOnly: true,
    );
  }

  Future<AiRequestResultModel> assignUserToTask(
      {required Ref ref,
      required AssignUserToTaskRequestModel actionRequest}) async {
    return ErrorRequestResultModel(
        resultForAi: 'Not implemented for request: ${actionRequest.toString()}',
        showOnly: true);
  }

  String? _getUserId(Ref ref) {
    final curAuthState = ref.read(curUserProvider);
    return curAuthState.value?.id;
  }

  AiRequestResultModel _handleNoAuth() {
    return ErrorRequestResultModel(resultForAi: 'No auth', showOnly: true);
  }
}
