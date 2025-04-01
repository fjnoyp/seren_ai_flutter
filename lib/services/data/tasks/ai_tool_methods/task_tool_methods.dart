/*
Method executors for: 

AiInfoRequestType.findTasks

AiActionRequestType.createTask
AiActionRequestType.updateTaskFields
AiActionRequestType.deleteTask
AiActionRequestType.assignUserToTask
*/
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/results/error_request_result_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_options_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_view_type.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/tasks_filtered_search_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/ai_date_parser.dart';
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
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/add_comment_to_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/create_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/delete_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/find_tasks_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/show_tasks_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/task_request_models.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/update_task_fields_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/edit_task_button.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/ai_tool_execution_utils.dart';
import 'package:seren_ai_flutter/widgets/search/search_modal.dart';
import 'package:seren_ai_flutter/services/ai/ai_context_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskToolMethods {
  // Threshold for string similarity (0.0 to 1.0)
  static const double _similarityThreshold = 0.6;
  static const double _differenceThreshold = 0.8;

// TODO p2: SHOW vs FIND tasks -
// Find tasks should be a db based backend search performed by the ai
// The result should have a SHOW ME button in case as well ...

// While show tasks should be shown here

  Future<AiRequestResultModel> findTasks(
      {required Ref ref,
      required FindTasksRequestModel infoRequest,
      bool allowToolUiActions = true}) async {
    // TODO p0 - support updated at filter and finding
    // This way user can find tasks that were updated in the last X days

    // === Validate Auth ===
    final curUser = ref.read(curUserProvider).valueOrNull;

    if (curUser == null) return _handleNoAuth();

    final selectedOrgId = ref.read(curSelectedOrgIdNotifierProvider);
    if (selectedOrgId == null) {
      return ErrorRequestResultModel(
        resultForAi: 'No org selected',
      );
    }

    // === Filter Notifier Control ===
    // We use filter notifier to control the selected filters in the search modal we will show
    const viewType = TaskFilterViewType.modalSearch;

    final context =
        ref.read(navigationServiceProvider).navigatorKey.currentContext!;

    final filterNotifier = ref.read(taskFilterStateProvider(viewType).notifier);

    // Clear all filters
    filterNotifier.clearAllFilters();

    // Clear the search query
    ref.read(taskSearchQueryProvider(viewType).notifier).state = '';

    if (allowToolUiActions && infoRequest.showToUser) {
      // Open modal
      try {
        ref.read(isSearchModalOpenProvider.notifier).state = true;
      } catch (e) {
        log('Error opening search modal: $e');
      }

      // Wait for the next frame to ensure the modal is rendered
      await WidgetsBinding.instance.endOfFrame;
    }

    // === Parse the AI Request into filter notifier filters ===

    // == TaskName
    if (infoRequest.taskName != null || infoRequest.taskDescription != null) {
      ref.read(taskSearchQueryProvider(viewType).notifier).state =
          '${infoRequest.taskName ?? ''} ${' ${infoRequest.taskDescription ?? ''}'}'
              .trim();
    }

    // == TaskStatus
    if (infoRequest.taskStatus != null) {
      filterNotifier
          .updateFilter(TFStatus.status(context, infoRequest.taskStatus!));
    }

    // == TaskPriority
    if (infoRequest.taskPriority != null) {
      filterNotifier.updateFilter(
          TFPriority.priority(context, infoRequest.taskPriority!));
    }

    // == TaskAssignees
    // Handle assignee filtering if provided
    if (infoRequest.assignedUserNames != null) {
      // Check if MYSELF is in the list, handle special case
      if (AiToolExecutionUtils.containsMyselfKeyword(
          infoRequest.assignedUserNames)) {
        filterNotifier.updateFilter(TFAssignees.byUserModel(ref, curUser));
      } else if (infoRequest.assignedUserNames!.isNotEmpty) {
        bool foundMatch = false;
        // TODO p2: we currently don't support multiple assignees filtering
        for (final userName in infoRequest.assignedUserNames!) {
          final selectedOrgId = ref.read(curSelectedOrgIdNotifierProvider);
          if (selectedOrgId != null) {
            final users =
                await ref.read(usersRepositoryProvider).searchUsersByName(
                      searchQuery: userName,
                      orgId: selectedOrgId,
                    );
            if (users.isNotEmpty) {
              filterNotifier.updateFilter(TFAssignees.byUser(ref,
                  userId: users.first.id,
                  firstName: users.first.firstName,
                  lastName: users.first.lastName));
              foundMatch = true;
            }
          }
        }
        // If we don't find a match, we can't just remove the filter
        // because the user has provided a list of assignees
        // So we return an error message to the AI
        if (!foundMatch) {
          return ErrorRequestResultModel(
            resultForAi:
                'No matching users found for ${infoRequest.assignedUserNames}',
          );
        }
      } else {
        // Provided an empty list of assignees
        filterNotifier.updateFilter(TFAssignees.unassigned(ref, context));
      }
    }

    // == TaskAuthor
    if (infoRequest.authorUserName != null) {
      if (AiToolExecutionUtils.isMyselfKeyword(infoRequest.authorUserName)) {
        filterNotifier.updateFilter(TFAuthorUser.byUserModel(ref, curUser));
      } else {
        bool foundMatch = false;
        final selectedOrgId = ref.read(curSelectedOrgIdNotifierProvider);
        if (selectedOrgId != null) {
          final users =
              await ref.read(usersRepositoryProvider).searchUsersByName(
                    searchQuery: infoRequest.authorUserName!,
                    orgId: selectedOrgId,
                  );
          if (users.isNotEmpty) {
            filterNotifier.updateFilter(TFAuthorUser.byUser(ref,
                userId: users.first.id,
                firstName: users.first.firstName,
                lastName: users.first.lastName));
            foundMatch = true;
          }
        }
        if (!foundMatch) {
          return ErrorRequestResultModel(
            resultForAi:
                'No matching user found for "${infoRequest.authorUserName}"',
          );
        }
      }
    }

    // == TaskProject
    if (infoRequest.parentProjectName != null) {
      final projects =
          await ref.read(projectsRepositoryProvider).searchProjectsByName(
                searchQuery: infoRequest.parentProjectName!,
                orgId: selectedOrgId,
              );

      if (projects.isNotEmpty) {
        filterNotifier.updateFilter(TFProject.byProject(
            projectId: projects.first.id, projectName: projects.first.name));
      } else {
        return ErrorRequestResultModel(
          resultForAi:
              'No matching project found for "${infoRequest.parentProjectName}"',
        );
      }
    }

    // == TaskDueDate
    if (infoRequest.taskDueDateStart != null ||
        infoRequest.taskDueDateEnd != null) {
      applyDateRangeFilter(
        filterNotifier: filterNotifier,
        context: context,
        startDateStr: infoRequest.taskDueDateStart,
        endDateStr: infoRequest.taskDueDateEnd,
        dateField: TaskFieldEnum.dueDate,
      );
    }

    // == TaskCreatedDate
    if (infoRequest.taskCreatedDateStart != null ||
        infoRequest.taskCreatedDateEnd != null) {
      applyDateRangeFilter(
        filterNotifier: filterNotifier,
        context: context,
        startDateStr: infoRequest.taskCreatedDateStart,
        endDateStr: infoRequest.taskCreatedDateEnd,
        dateField: TaskFieldEnum.createdAt,
      );
    }

    // == TaskUpdatedDate
    if (infoRequest.taskUpdatedDateStart != null ||
        infoRequest.taskUpdatedDateEnd != null) {
      applyDateRangeFilter(
        filterNotifier: filterNotifier,
        context: context,
        startDateStr: infoRequest.taskUpdatedDateStart,
        endDateStr: infoRequest.taskUpdatedDateEnd,
        dateField: TaskFieldEnum.updatedAt,
      );
    }

    // === Get Tasks for AI Result ===

    final searchService = ref.read(tasksFilteredSearchServiceProvider);
    final filteredTasks = await searchService.getFilteredTasks(
      viewType: viewType,
      searchQuery: ref.read(taskSearchQueryProvider(viewType)),
    );

    // Only take first 20 tasks to send to AI
    final tasksToSend = filteredTasks.take(20).toList();

    // Get AI-readable context for each task using AIContextService
    final aiContextService = ref.read(aiContextServiceProvider);
    final tasksToSendAiReadable = await Future.wait(
      tasksToSend.map((task) => aiContextService.getTaskContext(task.id)),
    );

    // Use the factory constructor to process search criteria
    return FindTasksResultModel.fromTasksAndRequest(
      tasks: tasksToSend,
      request: infoRequest,
      resultForAi:
          'Found ${filteredTasks.length} matching tasks: ${tasksToSendAiReadable.whereType<String>().toList()}',
      showOnly: allowToolUiActions && infoRequest.showToUser,
    );
  }

  void applyDateRangeFilter({
    required TaskFilterStateNotifier filterNotifier,
    required BuildContext context,
    String? startDateStr,
    String? endDateStr,
    required TaskFieldEnum dateField,
  }) {
    final start = startDateStr != null
        ? AiDateParser.parseIsoIntoLocalThenUTC(startDateStr)
        : null;
    final end = endDateStr != null
        ? AiDateParser.parseIsoIntoLocalThenUTC(endDateStr)!
            // Add 1 day to include the end date
            .add(const Duration(days: 1))
        : null;

    // Format dates for a user-friendly display
    String formatDate(DateTime date) {
      // Use intl package for proper internationalization
      final currentLocale = Localizations.localeOf(context).toString();
      final DateFormat formatter = DateFormat.MMMd(currentLocale);
      return formatter.format(date);
    }

    // Create a readable date range name
    String dateRangeName = '';
    if (start != null && end != null) {
      dateRangeName =
          '${formatDate(start)} - ${formatDate(end.subtract(const Duration(days: 1)))}';
    } else if (start != null) {
      // Use a symbol instead of the word "from"
      dateRangeName = '${formatDate(start)} →';
    } else if (end != null) {
      // Use a symbol instead of the word "until"
      dateRangeName = '→ ${formatDate(end.subtract(const Duration(days: 1)))}';
    } else {
      final appLocalizations = AppLocalizations.of(context);
      dateRangeName = appLocalizations?.customDateRange ?? 'custom range';
    }

    // Create the appropriate filter based on the field type
    final baseFilter = switch (dateField) {
      TaskFieldEnum.createdAt =>
        TFCreatedAt.customDateRangeWithName(context, dateRangeName),
      TaskFieldEnum.updatedAt =>
        TFUpdatedAt.customDateRangeWithName(context, dateRangeName),
      TaskFieldEnum.dueDate =>
        TFDueDate.customDateRangeWithName(context, dateRangeName),
      _ => TFDueDate.customDateRangeWithName(
          context, dateRangeName), // Default to due date for other fields
    };

    if (start != null && end != null) {
      filterNotifier.updateFilter(baseFilter.copyWith(
        condition: (task) {
          final date = switch (dateField) {
            TaskFieldEnum.createdAt => task.createdAt,
            TaskFieldEnum.updatedAt => task.updatedAt,
            TaskFieldEnum.dueDate => task.dueDate,
            _ => task.dueDate, // Default to due date for other fields
          };
          return date != null && date.isAfter(start) && date.isBefore(end);
        },
      ));
    } else if (start != null) {
      filterNotifier.updateFilter(baseFilter.copyWith(
        condition: (task) {
          final date = switch (dateField) {
            TaskFieldEnum.createdAt => task.createdAt,
            TaskFieldEnum.updatedAt => task.updatedAt,
            TaskFieldEnum.dueDate => task.dueDate,
            _ => task.dueDate, // Default to due date for other fields
          };
          return date != null && date.isAfter(start);
        },
      ));
    } else if (end != null) {
      filterNotifier.updateFilter(baseFilter.copyWith(
        condition: (task) {
          final date = switch (dateField) {
            TaskFieldEnum.createdAt => task.createdAt,
            TaskFieldEnum.updatedAt => task.updatedAt,
            TaskFieldEnum.dueDate => task.dueDate,
            _ => task.dueDate, // Default to due date for other fields
          };
          return date != null && date.isBefore(end);
        },
      ));
    }
  }

  // TODO p3: switch to pagination + db based FTS + semantic search
  Future<AiRequestResultModel> oldFindTasks(
      {required Ref ref, required FindTasksRequestModel infoRequest}) async {
    final userId = _getUserId(ref);
    if (userId == null) return _handleNoAuth();

    final selectedOrgId = ref.read(curSelectedOrgIdNotifierProvider);
    if (selectedOrgId == null) {
      return ErrorRequestResultModel(
        resultForAi: 'No org selected',
      );
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
    // final List<DateTime> dueDatesToGet = infoRequest.dueDatesToGet != null
    //     ? AiDateParser.parseDateList(infoRequest.dueDatesToGet!)
    //     : [];
    // final List<DateTime> createdDatesToGet =
    //     infoRequest.createdDatesToGet != null
    //         ? AiDateParser.parseDateList(infoRequest.createdDatesToGet!)
    //         : [];

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
      // if (infoRequest.getOverdueTasksOnly != null &&
      //     infoRequest.getOverdueTasksOnly!) {
      //   if (task.dueDate == null ||
      //       task.dueDate!.isAfter(DateTime.now().toUtc())) {
      //     return false;
      //   }
      // }

      // // Due date search
      // if (dueDatesToGet.isNotEmpty) {
      //   final dueDate = task.dueDate;

      //   if (dueDate == null ||
      //       !dueDatesToGet.any((dateToGet) => dueDate.isSameDate(dateToGet))) {
      //     return false;
      //   }
      // }

      // // Created date search
      // if (createdDatesToGet.isNotEmpty) {
      //   final createdDate = task.createdAt;

      //   if (createdDate == null ||
      //       !createdDatesToGet
      //           .any((dateToGet) => createdDate.isSameDate(dateToGet))) {
      //     return false;
      //   }
      // }

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

    // Get AI-readable context for each task using AIContextService
    final aiContextService = ref.read(aiContextServiceProvider);
    final tasksToSendAiReadable = await Future.wait(
      tasksToSend.map((task) => aiContextService.getTaskContext(task.id)),
    );

    return FindTasksResultModel(
      tasks: tasksToSend,
      resultForAi:
          'Found ${filteredTasks.length} matching tasks: ${tasksToSendAiReadable.whereType<String>().toList()}',
    );
  }

  Future<AiRequestResultModel> createTask(
      {required Ref ref,
      required CreateTaskRequestModel actionRequest,
      bool allowToolUiActions = true}) async {
    final userId = _getUserId(ref);
    if (userId == null) return _handleNoAuth();

    // === SELECT PROJECT ===
    final selectedProjectId = await ref
        .read(searchProjectsServiceProvider)
        .searchProjectNameToId(actionRequest.parentProjectName);

    if (selectedProjectId == null) {
      return ErrorRequestResultModel(
        resultForAi:
            'No project found with name "${actionRequest.parentProjectName}"',
      );
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
    if (allowToolUiActions && actionRequest.showToUser) {
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

      log('opened task page');
    } else {
      log('did not open task page, UI actions are not allowed');
    }

    // Use the factory constructor to process created fields
    return CreateTaskResultModel.fromTaskAndRequest(
      task: newTask,
      request: actionRequest,
      userAssignmentResults: userAssignmentResults,
      resultForAi: actionRequest.showToUser
          ? 'Created new task "${newTask.name}" and opened task page'
          : 'Created new task "${newTask.name}"',
    );
  }

  Future<AiRequestResultModel> updateTaskFields(
      {required Ref ref,
      required UpdateTaskFieldsRequestModel actionRequest,
      bool allowToolUiActions = true}) async {
    final selectedOrgId = ref.read(curSelectedOrgIdNotifierProvider);
    if (selectedOrgId == null) {
      return ErrorRequestResultModel(
        resultForAi: 'No org selected',
      );
    }
    final matchingTasks =
        await ref.read(tasksRepositoryProvider).searchTasksByName(
              searchQuery: actionRequest.taskName,
              orgId: selectedOrgId,
            );

    // TODO p2: determine task matching logic - may want to ask user for confirmation or add a good undo
    // For now - just update the first matching task
    if (matchingTasks.isEmpty) {
      return ErrorRequestResultModel(
        resultForAi: 'No matching tasks found',
      );
    }

    final taskToModify = matchingTasks.first;

    // === SELECT PROJECT ===
    String? selectedProjectId;
    Map<String, Map<String, dynamic>> additionalChanges = {};

    if (actionRequest.parentProjectName != null) {
      selectedProjectId = await ref
          .read(searchProjectsServiceProvider)
          .searchProjectNameToId(actionRequest.parentProjectName);

      if (selectedProjectId == null) {
        return ErrorRequestResultModel(
          resultForAi:
              'No project found with name "${actionRequest.parentProjectName}"',
        );
      }

      // Project changes require repository access, so we handle them separately
      if (selectedProjectId != taskToModify.parentProjectId) {
        final oldProject = await ref
            .read(projectsRepositoryProvider)
            .getById(taskToModify.parentProjectId);
        final newProject = await ref
            .read(projectsRepositoryProvider)
            .getById(selectedProjectId);

        additionalChanges['project'] = {
          'old': oldProject?.name,
          'new': newProject?.name,
        };
      }
    }
    // === END SELECT PROJECT ===

    // Build updated task
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
      parentProjectId: selectedProjectId ?? taskToModify.parentProjectId,
    );

    // Navigate to task page if allowed
    if (allowToolUiActions && actionRequest.showToUser) {
      ref
          .read(curSelectedTaskIdNotifierProvider.notifier)
          .setTaskId(updatedTask.id);

      final navigationService = ref.read(navigationServiceProvider);

      navigationService.navigateTo(AppRoutes.taskPage.name, arguments: {
        'mode': EditablePageMode.readOnly,
        'actions': [EditTaskButton(updatedTask.id)],
        'title': updatedTask.name,
      });

      log('opened task page');
    } else {
      log('did not open task page, UI actions are not allowed');
    }

    // Save task changes
    await ref.read(tasksRepositoryProvider).upsertItem(updatedTask);

    // Handle assignees
    if (actionRequest.assignedUserNames != null &&
        actionRequest.assignedUserNames!.isNotEmpty) {
      // Get current assignees for comparison
      final currentAssignees = await ref
          .read(usersRepositoryProvider)
          .getTaskAssignedUsers(taskId: updatedTask.id);

      // Track assignee changes
      additionalChanges['assignees'] = {
        'old': currentAssignees
            .map((u) => '${u.firstName} ${u.lastName}')
            .toList(),
        'new': actionRequest.assignedUserNames,
      };

      List<String> assignedUserNames = actionRequest.assignedUserNames!;

      // Handle MYSELF keyword
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

    // Use the factory constructor to process changes
    return UpdateTaskFieldsResultModel.fromTaskAndRequest(
      originalTask: taskToModify,
      updatedTask: updatedTask,
      request: actionRequest,
      resultForAi: actionRequest.showToUser
          ? 'Updated task "${updatedTask.name}" and showed result in UI'
          : 'Updated task "${updatedTask.name}"',
      additionalChanges: additionalChanges,
    );
  }

  Future<AiRequestResultModel> deleteTask(
      {required Ref ref, required DeleteTaskRequestModel actionRequest}) async {
    final selectedOrgId = ref.read(curSelectedOrgIdNotifierProvider);
    if (selectedOrgId == null) {
      return ErrorRequestResultModel(
        resultForAi: 'No org selected',
      );
    }
    final foundTasks =
        await ref.read(tasksRepositoryProvider).searchTasksByName(
              searchQuery: actionRequest.taskName,
              orgId: selectedOrgId,
            );

    if (foundTasks.isEmpty) {
      return ErrorRequestResultModel(
        resultForAi: 'Task not found',
      );
    } else if (foundTasks.length > 1) {
      // TODO p3: handle this case
      return ErrorRequestResultModel(
        resultForAi:
            'Multiple tasks found with name "${actionRequest.taskName}"',
      );
    }

    // If the task is found, move on to deleting it
    final toDeleteTask = foundTasks.first;

    if (actionRequest.showToUser) {
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
      );
    } else {
      // Delete the task without showing UI
      await ref.read(tasksRepositoryProvider).deleteItem(toDeleteTask.id);

      return DeleteTaskResultModel(
        resultForAi: 'Successfully deleted task "${toDeleteTask.name}"',
        isDeleted: true,
        taskName: toDeleteTask.name,
      );
    }
  }

  Future<AiRequestResultModel> addCommentToTask(
      {required Ref ref,
      required AddCommentToTaskRequestModel actionRequest,
      bool allowToolUiActions = true}) async {
    final userId = _getUserId(ref);
    if (userId == null) return _handleNoAuth();
    final selectedOrgId = ref.read(curSelectedOrgIdNotifierProvider);
    if (selectedOrgId == null) {
      return ErrorRequestResultModel(
        resultForAi: 'No org selected',
      );
    }

    // Find the task by name
    final matchingTasks =
        await ref.read(tasksRepositoryProvider).searchTasksByName(
              searchQuery: actionRequest.taskName,
              orgId: selectedOrgId,
            );

    if (matchingTasks.isEmpty) {
      return ErrorRequestResultModel(
        resultForAi:
            'No matching tasks found with the name "${actionRequest.taskName}"',
      );
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

    // Update task view if available and showToUser is true
    if (allowToolUiActions && actionRequest.showToUser) {
      ref
          .read(curSelectedTaskIdNotifierProvider.notifier)
          .setTaskId(taskToComment.id);

      final navigationService = ref.read(navigationServiceProvider);
      navigationService.navigateTo(AppRoutes.taskPage.name, arguments: {
        'mode': EditablePageMode.readOnly,
        'actions': [EditTaskButton(taskToComment.id)],
      });
    }

    return AddCommentToTaskResultModel(
      comment: comment,
      task: taskToComment,
      resultForAi: 'Added comment to task "${taskToComment.name}"',
    );
  }

  Future<AiRequestResultModel> showTask(
      {required Ref ref, required ShowTasksRequestModel actionRequest}) async {
    final userId = _getUserId(ref);
    if (userId == null) return _handleNoAuth();

    final selectedOrgId = ref.read(curSelectedOrgIdNotifierProvider);
    if (selectedOrgId == null) {
      return ErrorRequestResultModel(
        resultForAi: 'No org selected',
      );
    }

    final navigationService = ref.read(navigationServiceProvider);

    // If showToUser is false, just return information without showing in UI
    if (!actionRequest.showToUser) {
      return ShowTasksResultModel(
        resultForAi: 'Task data retrieved but not shown in UI as per request.',
      );
    }

    // Case 1: Show a single task by name or id
    if (actionRequest.taskName != null || actionRequest.taskId != null) {
      TaskModel? taskToShow;

      // If task ID is provided, fetch directly
      if (actionRequest.taskId != null) {
        taskToShow = await ref
            .read(tasksRepositoryProvider)
            .getById(actionRequest.taskId!);
      }
      // Otherwise find by name using similarity
      else if (actionRequest.taskName != null) {
        final matchingTasks =
            await ref.read(tasksRepositoryProvider).searchTasksByName(
                  searchQuery: actionRequest.taskName!,
                  orgId: selectedOrgId,
                );
        if (matchingTasks.isNotEmpty) {
          taskToShow = matchingTasks.first;
        }
      }

      if (taskToShow == null) {
        return ErrorRequestResultModel(
          resultForAi:
              'No matching task found for "${actionRequest.taskName ?? actionRequest.taskId}"',
        );
      }

      // Navigate to task details page
      ref.read(taskNavigationServiceProvider).openTask(
            initialTaskId: taskToShow.id,
            withReplacement: true,
          );

      return ShowTasksResultModel(
        resultForAi: 'Showing task "${taskToShow.name}"',
      );
    }
    // Case 2: Show a tasks list/view based on type
    else {
      // Handle different view types
      switch (actionRequest.taskType) {
        case TaskViewType.recentTasks:
          ref.read(navigationServiceProvider).navigateTo(AppRoutes.home.name,
              arguments: {'initialTab': 0}); // Recent tab index
          return ShowTasksResultModel(
            resultForAi: 'Showing recent tasks',
          );

        case TaskViewType.myTasks:
          ref.read(navigationServiceProvider).navigateTo(AppRoutes.home.name,
              arguments: {'initialTab': 1}); // My Tasks tab index
          return ShowTasksResultModel(
            resultForAi: 'Showing my tasks',
          );

        case TaskViewType.projectGanttTasks:
        case TaskViewType.projectTasks:
          // If project name is provided, find the project first
          if (actionRequest.parentProjectName != null) {
            final projectId = await ref
                .read(searchProjectsServiceProvider)
                .searchProjectNameToId(actionRequest.parentProjectName);

            if (projectId == null) {
              return ErrorRequestResultModel(
                resultForAi:
                    'No project found with name "${actionRequest.parentProjectName}"',
              );
            }

            // Navigate to the appropriate project view
            if (actionRequest.taskType == TaskViewType.projectGanttTasks) {
              // TODO p2 - use gantt page deep link
              ref
                  .read(projectNavigationServiceProvider)
                  .openProjectPage(projectId: projectId);
              return ShowTasksResultModel(
                resultForAi:
                    'Showing Gantt view for project "${actionRequest.parentProjectName}"',
              );
            } else {
              ref
                  .read(projectNavigationServiceProvider)
                  .openProjectPage(projectId: projectId);
              return ShowTasksResultModel(
                resultForAi:
                    'Showing tasks for project "${actionRequest.parentProjectName}"',
              );
            }
          } else {
            return ErrorRequestResultModel(
              resultForAi: 'Project name is required for project task views',
            );
          }

        default:
          return ErrorRequestResultModel(
            resultForAi:
                'Unsupported task view type: ${actionRequest.taskType}',
          );
      }
    }
  }

  String? _getUserId(Ref ref) {
    final curAuthState = ref.read(curUserProvider);
    return curAuthState.value?.id;
  }

  AiRequestResultModel _handleNoAuth() {
    return ErrorRequestResultModel(
      resultForAi: 'No auth',
    );
  }
}
