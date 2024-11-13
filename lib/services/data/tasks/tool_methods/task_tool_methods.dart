/*
Method executors for: 

AiInfoRequestType.findTasks

AiActionRequestType.createTask
AiActionRequestType.updateTaskFields
AiActionRequestType.deleteTask
AiActionRequestType.assignUserToTask
*/
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/error_request_result_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/utils/string_similarity_extension.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/joined_task_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/find_tasks_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/task_request_models.dart';
import 'dart:math';

class TaskToolMethods {
  // Threshold for string similarity (0.0 to 1.0)
  static const double _similarityThreshold = 0.6;
  static const double _differenceThreshold = 0.8;

  Future<AiRequestResultModel> findTasks(
      {required Ref ref, required FindTasksRequestModel infoRequest}) async {
    final userId = _getUserId(ref);
    if (userId == null) return _handleNoAuth();

    final joinedTasks = await ref
        .read(joinedTasksRepositoryProvider)
        .getUserViewableJoinedTasks(userId);

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

      // Due date search with radius
      if (infoRequest.taskDueDate != null) {
        final searchDate = DateTime.tryParse(infoRequest.taskDueDate!);
        if (searchDate != null && task.dueDate != null) {
          final difference = searchDate.difference(task.dueDate!).inDays.abs();
          if (difference > (infoRequest.dateSearchRadiusDays ?? 0)) {
            return false;
          }
        }
      }

      // Created date search with radius
      if (infoRequest.taskCreatedDate != null && task.createdAt != null) {
        final searchDate = DateTime.tryParse(infoRequest.taskCreatedDate!);
        if (searchDate != null) {
          final difference =
              searchDate.difference(task.createdAt!).inDays.abs();
          if (difference > (infoRequest.dateSearchRadiusDays ?? 0)) {
            return false;
          }
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
      resultForAi: 'Found ${filteredTasks.length} matching tasks: ${filteredTasks.map((task) => task.toReadableMap()).toList()}',
      showOnly: infoRequest.showOnly,
    );
  }

  Future<AiRequestResultModel> createTask(
      {required Ref ref, required CreateTaskRequestModel actionRequest}) async {
    return ErrorRequestResultModel(
        resultForAi: 'Not implemented for request: ${actionRequest.toString()}',
        showOnly: true);
  }

  Future<AiRequestResultModel> updateTaskFields(
      {required Ref ref,
      required UpdateTaskFieldsRequestModel actionRequest}) async {
    return ErrorRequestResultModel(
        resultForAi: 'Not implemented for request: ${actionRequest.toString()}',
        showOnly: true);
  }

  Future<AiRequestResultModel> deleteTask(
      {required Ref ref, required DeleteTaskRequestModel actionRequest}) async {
    return ErrorRequestResultModel(
        resultForAi: 'Not implemented for request: ${actionRequest.toString()}',
        showOnly: true);
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
