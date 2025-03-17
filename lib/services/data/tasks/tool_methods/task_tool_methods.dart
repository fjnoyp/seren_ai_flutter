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
import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/results/error_request_result_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/ai_date_parser.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/utils/string_similarity_extension.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/search_projects_service.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comment_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_assignments_service_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_comments_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/add_comment_to_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/create_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/delete_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/find_tasks_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/task_request_models.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/update_task_fields_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/edit_task_button.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/ai_tool_execution_utils.dart';

class TaskToolMethods {
  // Threshold for string similarity (0.0 to 1.0)
  static const double _similarityThreshold = 0.6;
  static const double _differenceThreshold = 0.8;

  // TODO p3: switch to pagination + db based FTS + semantic search
  Future<AiRequestResultModel> findTasks(
      {required Ref ref, required FindTasksRequestModel infoRequest}) async {
    final userId = _getUserId(ref);
    if (userId == null) return _handleNoAuth();

    final selectedOrgId = ref.watch(curSelectedOrgIdNotifierProvider);
    if (selectedOrgId == null) {
      return ErrorRequestResultModel(
          resultForAi: 'No org selected', showOnly: true);
    }

    final allTasks = await ref
        .read(tasksRepositoryProvider)
        .getUserViewableTasks(userId: userId, orgId: selectedOrgId);

    // Pre-fetch all projects and authors
    final projectsMap = <String, ProjectModel?>{};
    final authorsMap = <String, UserModel?>{};
    final assigneesMap = <String, List<UserModel>>{};

    for (final task in allTasks) {
      projectsMap[task.parentProjectId] = await ref
          .read(projectsRepositoryProvider)
          .getById(task.parentProjectId);
      authorsMap[task.authorUserId] =
          await ref.read(usersRepositoryProvider).getById(task.authorUserId);
      assigneesMap[task.id] = await ref
          .read(usersRepositoryProvider)
          .getTaskAssignedUsers(taskId: task.id);
    }

    // Get a list of dates to allow for due date search
    final List<DateTime> dueDatesToGet = infoRequest.dueDatesToGet != null
        ? AiDateParser.parseDateList(infoRequest.dueDatesToGet!)
        : [];
    final List<DateTime> createdDatesToGet =
        infoRequest.createdDatesToGet != null
            ? AiDateParser.parseDateList(infoRequest.createdDatesToGet!)
            : [];

    // Filter tasks based on search criteria
    final filteredTasks = allTasks.where((task) {
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
      final project = projectsMap[task.parentProjectId];
      if (infoRequest.parentProjectName != null &&
          project != null &&
          project.name.similarity(infoRequest.parentProjectName!) <
              _similarityThreshold) {
        return false;
      }

      // Author email / username search with fuzzy matching or MYSELF match
      final author = authorsMap[task.authorUserId];
      if (infoRequest.authorUserName != null) {
        if (AiToolExecutionUtils.isMyselfKeyword(infoRequest.authorUserName)) {
          // Special case for "MYSELF" to match current user
          if (userId != task.authorUserId) {
            return false;
          }
        } else if (author != null &&
            author.email.similarity(infoRequest.authorUserName!) <
                _similarityThreshold) {
          return false;
        }
      }

      // --- Keep exact matching for non-string fields:

      // Status match
      final status = StatusEnum.tryParse(infoRequest.taskStatus);
      if (infoRequest.taskStatus != null &&
          (task.status == null || task.status != status)) {
        return false;
      }

      // Priority match
      final priority = PriorityEnum.tryParse(infoRequest.taskPriority);
      if (infoRequest.taskPriority != null &&
          (task.priority == null || task.priority != priority)) {
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
      if (dueDatesToGet.isNotEmpty) {
        final dueDate = task.dueDate;

        if (dueDate == null ||
            !dueDatesToGet.any((dateToGet) => dueDate.isSameDate(dateToGet))) {
          return false;
        }
      }

      // Created date search
      if (createdDatesToGet.isNotEmpty) {
        final createdDate = task.createdAt;

        if (createdDate == null ||
            !createdDatesToGet
                .any((dateToGet) => createdDate.isSameDate(dateToGet))) {
          return false;
        }
      }

      // Duration estimate match
      if (infoRequest.estimateDurationMinutes != null &&
          (task.estimatedDurationMinutes == null ||
              task.estimatedDurationMinutes! <
                  infoRequest.estimateDurationMinutes! * 0.5 ||
              task.estimatedDurationMinutes! >
                  infoRequest.estimateDurationMinutes! * 1.5)) {
        return false;
      }

      // Assigned users match using similarity calculation or MYSELF match
      final assignedUsers = assigneesMap[task.id];
      if (infoRequest.assignedUserNames != null && assignedUsers != null) {
        if (AiToolExecutionUtils.containsMyselfKeyword(
            infoRequest.assignedUserNames)) {
          // Check if current user is assigned to this task
          if (!assignedUsers.any((user) => user.id == userId)) {
            return false;
          }
        } else {
          // Standard similarity matching for user names
          final taskAssigneeNames =
              assignedUsers.map((u) => u.email.toLowerCase()).toList();
          final searchNames = infoRequest.assignedUserNames!
              .map((n) => n.toLowerCase())
              .toList();

          // Calculate similarity and check if any search name matches task assignee names
          if (!searchNames.any((searchName) => taskAssigneeNames.any(
              (taskName) =>
                  searchName.similarity(taskName) > _differenceThreshold))) {
            return false;
          }
        }
      }

      return true;
    }).toList();

    const maxTasksToSend = 20;
    final tasksToSend = filteredTasks.take(maxTasksToSend).toList();

    return FindTasksResultModel(
      tasks: tasksToSend,
      resultForAi:
          'Found ${filteredTasks.length} matching tasks: ${tasksToSend.map((task) => task.toAiReadableMap(project: projectsMap[task.parentProjectId], author: authorsMap[task.authorUserId], assignees: assigneesMap[task.id])).toList()}',
      showOnly: infoRequest.showOnly,
    );
  }

  Future<AiRequestResultModel> createTask(
      {required Ref ref,
      required CreateTaskRequestModel actionRequest,
      required bool allowToolUiActions}) async {
    final userId = _getUserId(ref);
    if (userId == null) return _handleNoAuth();

    // === SELECT PROJECT ===
    final selectedProjectId = await ref
        .read(searchProjectsServiceProvider)
        .selectProject(actionRequest.parentProjectName);

    if (selectedProjectId == null) {
      return ErrorRequestResultModel(
          resultForAi:
              'No project found with name "${actionRequest.parentProjectName}"',
          showOnly: true);
    }
    // === END SELECT PROJECT ===

    // Create a new task with fields from the request
    final newTask = TaskModel(
      name: actionRequest.taskName,
      description: actionRequest.taskDescription,
      startDateTime:
          AiDateParser.parseIsoIntoLocalThenUTC(actionRequest.taskStartDate),
      dueDate: AiDateParser.parseIsoIntoLocalThenUTC(actionRequest.taskDueDate),
      status: actionRequest.taskStatus != null
          ? StatusEnum.tryParse(actionRequest.taskStatus)
          : StatusEnum.open,
      priority: actionRequest.taskPriority != null
          ? PriorityEnum.tryParse(actionRequest.taskPriority)
          : null,
      estimatedDurationMinutes: actionRequest.estimateDurationMinutes,
      authorUserId: userId,
      // TODO p4: add `actionRequest.parentProjectId` instead of always using defaultProjectId
      parentProjectId: selectedProjectId,
      type: TaskType.task,
    );

    // Save the task in the current task service
    await ref.read(tasksRepositoryProvider).upsertItem(newTask);

    // === ASSIGN USERS TO TASK ===
    List<SearchUserResult>? userAssignmentResults;
    if (actionRequest.assignedUserNames != null &&
        actionRequest.assignedUserNames!.isNotEmpty) {
      List<String> assignedUserNames = actionRequest.assignedUserNames!;

      // Check if MYSELF is in the list, and if so swap with current user id
      if (AiToolExecutionUtils.containsMyselfKeyword(
          actionRequest.assignedUserNames)) {
        assignedUserNames.removeWhere((name) => name == "MYSELF");
        ref.read(taskAssignmentsServiceProvider).addAssignee(
              newTask.id,
              userId,
            );
      }

      userAssignmentResults = await ref
          .read(taskAssignmentsServiceProvider)
          .tryAssignUsersByName(newTask.id, assignedUserNames);
    }
    // === END ASSIGN USERS TO TASK ===
    // Navigate to task page in readOnly mode
    if (allowToolUiActions) {
      ref
          .read(curSelectedTaskIdNotifierProvider.notifier)
          .setTaskId(newTask.id);

      final navigationService = ref.read(navigationServiceProvider);

      // Do not await - this never returns
      navigationService.navigateTo(AppRoutes.taskPage.name, arguments: {
        'mode': EditablePageMode.readOnly,
        'actions': [EditTaskButton(newTask.id)],
        'title': newTask.name,
      });

      log('and opened task page');
    } else {
      log('but UI actions are not allowed');
    }

    return CreateTaskResultModel(
      task: newTask,
      userAssignmentResults: userAssignmentResults,
      resultForAi: allowToolUiActions
          ? 'Created new task "${newTask.name}" and opened task page'
          : 'Created new task "${newTask.name}"',
      showOnly: true,
    );
  }

  // TODO p2: move this to a db method
  // Finds the tasks with the highest similarity to the search task name
  Future<List<TaskModel>> _getTasksByName(
      Ref ref, String searchTaskName) async {
    final userId = _getUserId(ref);
    if (userId == null) return [];

    final selectedOrgId = ref.watch(curSelectedOrgIdNotifierProvider);
    if (selectedOrgId == null) return [];

    final allTasks = await ref
        .read(tasksRepositoryProvider)
        .getUserViewableTasks(userId: userId, orgId: selectedOrgId);

    // Calculate similarity scores and sort
    final tasksWithScores = allTasks
        .map((task) {
          final similarity = task.name.similarity(searchTaskName);
          return (task, similarity);
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
    final matchingTasks = await _getTasksByName(ref, actionRequest.taskName);

    // TODO p2: determine task matching logic - may want to ask user for confirmation or add a good undo
    // For now - just update the first matching task
    if (matchingTasks.isEmpty) {
      return ErrorRequestResultModel(
          resultForAi: 'No matching tasks found', showOnly: true);
    }

    final taskToModify = matchingTasks.first;

    // === SELECT PROJECT ===
    final selectedProjectId = await ref
        .read(searchProjectsServiceProvider)
        .selectProject(actionRequest.parentProjectName);

    if (selectedProjectId == null) {
      return ErrorRequestResultModel(
          resultForAi:
              'No project found with name "${actionRequest.parentProjectName}"',
          showOnly: true);
    }
    // === END SELECT PROJECT ===

    final updatedTask = taskToModify.copyWith(
      name: actionRequest.taskName,
      description: actionRequest.taskDescription,
      startDateTime:
          AiDateParser.parseIsoIntoLocalThenUTC(actionRequest.taskStartDate),
      dueDate: AiDateParser.parseIsoIntoLocalThenUTC(actionRequest.taskDueDate),
      status: actionRequest.taskStatus != null
          ? StatusEnum.tryParse(actionRequest.taskStatus)
          : null,
      priority: actionRequest.taskPriority != null
          ? PriorityEnum.tryParse(actionRequest.taskPriority)
          : null,
      estimatedDurationMinutes: actionRequest.estimateDurationMinutes,
      updatedAt: DateTime.now().toUtc(),
      parentProjectId: selectedProjectId,
    );

    // Show the new task fields and ask for confirmation

    if (allowToolUiActions) {
      ref
          .read(curSelectedTaskIdNotifierProvider.notifier)
          .setTaskId(updatedTask.id);
    }

    // Save task changes ...
    await ref.read(tasksRepositoryProvider).upsertItem(updatedTask);

    // Try to assign users by name
    if (actionRequest.assignedUserNames != null &&
        actionRequest.assignedUserNames!.isNotEmpty) {
      List<String> assignedUserNames = actionRequest.assignedUserNames!;

      // Check if MYSELF is in the list, and if so swap with current user id
      if (AiToolExecutionUtils.containsMyselfKeyword(
          actionRequest.assignedUserNames)) {
        final userId = _getUserId(ref);
        if (userId != null) {
          assignedUserNames.removeWhere((name) => name == "MYSELF");
          ref.read(taskAssignmentsServiceProvider).addAssignee(
                updatedTask.id,
                userId,
              );
        }
      }

      await ref
          .read(taskAssignmentsServiceProvider)
          .tryAssignUsersByName(updatedTask.id, assignedUserNames);
    }

    return UpdateTaskFieldsResultModel(
      task: updatedTask,
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

    final selectedOrgId = ref.watch(curSelectedOrgIdNotifierProvider);
    if (selectedOrgId == null) {
      return ErrorRequestResultModel(
          resultForAi: 'No org selected', showOnly: true);
    }

    final joinedTasks = await ref
        .read(tasksRepositoryProvider)
        .getUserViewableTasks(userId: userId, orgId: selectedOrgId);

    final filteredTasks = joinedTasks.where((task) =>
        task.name.similarity(actionRequest.taskName) >= _similarityThreshold);

    if (filteredTasks.isEmpty) {
      return ErrorRequestResultModel(
          resultForAi: 'Task not found', showOnly: true);
    } else if (filteredTasks.length > 1) {
      // TODO p3: handle this case
      return ErrorRequestResultModel(
        resultForAi:
            'Multiple tasks found with name "${actionRequest.taskName}"',
        showOnly: true,
      );
    }

    // If the task is found, move on to deleting it
    final toDeleteTask = filteredTasks.first;
    ref
        .read(curSelectedTaskIdNotifierProvider.notifier)
        .setTaskId(toDeleteTask.id);

    final navigationService = ref.read(navigationServiceProvider);
    final deleted = await navigationService.showPopupDialog(
      DeleteConfirmationDialog(
        itemName: toDeleteTask.name,
        onDelete: () async {
          await ref.read(tasksRepositoryProvider).deleteItem(toDeleteTask.id);
        },
      ),
    );

    return DeleteTaskResultModel(
      resultForAi: deleted == true
          ? 'Successfully deleted task "${toDeleteTask.name}"'
          : 'Task deletion cancelled by user for "${toDeleteTask.name}"',
      isDeleted: deleted,
      taskName: toDeleteTask.name,
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

  Future<AiRequestResultModel> addCommentToTask(
      {required Ref ref,
      required AddCommentToTaskRequestModel actionRequest}) async {
    final userId = _getUserId(ref);
    if (userId == null) return _handleNoAuth();

    // Find the task by name
    final matchingTasks = await _getTasksByName(ref, actionRequest.taskName);

    if (matchingTasks.isEmpty) {
      return ErrorRequestResultModel(
          resultForAi:
              'No matching tasks found with the name "${actionRequest.taskName}"',
          showOnly: true);
    }

    final taskToComment = matchingTasks.first;

    // Create and save the comment
    final comment = TaskCommentModel(
      authorUserId: userId,
      parentTaskId: taskToComment.id,
      content: actionRequest.comment,
      createdAt: DateTime.now().toUtc(),
    );

    // Save the comment to the repository
    await ref.read(taskCommentsRepositoryProvider).insertItem(comment);

    // Update task view if available
    ref
        .read(curSelectedTaskIdNotifierProvider.notifier)
        .setTaskId(taskToComment.id);

    return AddCommentToTaskResultModel(
      comment: comment,
      task: taskToComment,
      resultForAi: 'Added comment to task "${taskToComment.name}"',
      showOnly: true,
    );
  }

  String? _getUserId(Ref ref) {
    final curAuthState = ref.read(curUserProvider);
    return curAuthState.value?.id;
  }

  AiRequestResultModel _handleNoAuth() {
    return ErrorRequestResultModel(resultForAi: 'No auth', showOnly: true);
  }
}
