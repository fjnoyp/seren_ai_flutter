import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/utils/date_time_extension.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/users/providers/user_in_project_provider.dart';
import 'package:seren_ai_flutter/services/data/users/providers/task_assigned_users_stream_provider.dart';

enum TaskFilterOption {
  type,
  assignees,
  dueDate,
  priority,
  creationDate;

  String getDisplayName(BuildContext context) {
    switch (this) {
      case TaskFilterOption.assignees:
        return AppLocalizations.of(context)!.assignees;
      case TaskFilterOption.dueDate:
        return AppLocalizations.of(context)!.dueDate;
      case TaskFilterOption.priority:
        return AppLocalizations.of(context)!.priority;
      case TaskFilterOption.creationDate:
        return AppLocalizations.of(context)!.createdAt;
      case TaskFilterOption.type:
        return AppLocalizations.of(context)!.type;
    }
  }

  List<({String value, String name, bool Function(TaskModel, WidgetRef ref)? filter})>
      getSubOptions(BuildContext context, WidgetRef ref) {
    switch (this) {
      case TaskFilterOption.assignees:
        final projectId = ref.watch(curSelectedProjectStreamProvider).value?.id;
        if (projectId == null) return []; // Handle null projectId

        return [
          ...(ref.watch(usersInProjectProvider(projectId)).value?.map((e) {
                // Create a new function that captures only what it needs
                final userId = e.id;
                bool filterFunction(task, ref) {
                  final assignees = ref
                          .read(taskAssignedUsersStreamProvider(
                              task.id)) // Use read instead of watch
                          .value ??
                      [];
                  return assignees.any((assignee) => assignee.id == userId);
                }

                return (
                  value: e.id,
                  name: '${e.firstName} ${e.lastName}',
                  filter: filterFunction
                );
              }) ??
              []),
          (
            value: 'notAssigned',
            name: AppLocalizations.of(context)!.notAssigned,
            filter: (task, ref) =>
                ref
                    .read(taskAssignedUsersStreamProvider(task.id))
                    .value
                    ?.isEmpty ??
                true
          )
        ];

      case TaskFilterOption.dueDate:
        return [
          (
            value: 'overdue',
            name: AppLocalizations.of(context)!.overdue,
            filter: (task, ref) => task.dueDate?.isBefore(DateTime.now()) ?? false
          ),
          (
            value: 'today',
            name: AppLocalizations.of(context)!.today,
            filter: (task, ref) => task.dueDate?.isSameDate(DateTime.now()) ?? false
          ),
          (
            value: 'thisWeek',
            name: AppLocalizations.of(context)!.thisWeek,
            filter: (task, ref) => task.dueDate?.isSameWeek(DateTime.now()) ?? false
          ),
          (
            value: 'thisMonth',
            name: AppLocalizations.of(context)!.thisMonth,
            filter: (task, ref) => task.dueDate?.isSameMonth(DateTime.now()) ?? false
          ),
          (
            value: 'customDateRange',
            name: AppLocalizations.of(context)!.customDateRange,
            filter: null
          ),
        ];

      case TaskFilterOption.priority:
        return PriorityEnum.values
            .map((e) => (
                  value: e.name,
                  name: e.toHumanReadable(context),
                  filter: (task, ref) => task.priority == e
                ))
            .toList();

      case TaskFilterOption.creationDate:
        return [
          (
            value: 'today',
            name: AppLocalizations.of(context)!.today,
            filter: (task, ref) =>
                task.createdAt?.isSameDate(DateTime.now()) ?? false
          ),
          (
            value: 'thisWeek',
            name: AppLocalizations.of(context)!.thisWeek,
            filter: (task, ref) =>
                task.createdAt?.isSameWeek(DateTime.now()) ?? false
          ),
          (
            value: 'thisMonth',
            name: AppLocalizations.of(context)!.thisMonth,
            filter: (task, ref) =>
                task.createdAt?.isSameMonth(DateTime.now()) ?? false
          ),
          (
            value: 'customDateRange',
            name: AppLocalizations.of(context)!.customDateRange,
            filter: null
          ),
        ];

      case TaskFilterOption.type:
        return TaskType.values
            .map((e) => (
                  value: e.name,
                  name: e.toHumanReadable(context),
                  filter: (task, ref) => task.type == e
                ))
            .toList();
    }
  }

  bool Function(TaskModel, DateTimeRange?) get filterFunction => switch (this) {
        TaskFilterOption.assignees => (task, _) => true,
        TaskFilterOption.dueDate => (task, dateRange) => dateRange != null
            ? (task.dueDate?.isAfter(dateRange.start) ?? false) &&
                (task.dueDate?.isBefore(dateRange.end) ?? false)
            : true,
        TaskFilterOption.priority => (task, _) => true,
        TaskFilterOption.creationDate => (task, dateRange) => dateRange != null
            ? (task.createdAt?.isAfter(dateRange.start) ?? false) &&
                (task.createdAt?.isBefore(dateRange.end) ?? false)
            : true,
        TaskFilterOption.type => (task, _) => true,
      };
}
