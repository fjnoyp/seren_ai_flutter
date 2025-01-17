import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/utils/date_time_extension.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/users/providers/user_in_project_provider.dart';
import 'package:seren_ai_flutter/services/data/users/providers/assigned_users_in_task_stream_provider.dart';

enum TaskFilterOption {
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
    }
  }

  List<({String value, String name, bool Function(TaskModel)? filter})>
      getSubOptions(BuildContext context, WidgetRef ref) {
    switch (this) {
      case TaskFilterOption.assignees:
        return ref
                .watch(usersInProjectProvider(
                    ref.watch(curSelectedProjectStreamProvider).value!.id))
                .value
                ?.map((e) => (
                      value: e.id,
                      name: '${e.firstName} ${e.lastName}',
                      filter: (TaskModel task) {
                        final assignees = ref
                                .watch(
                                    assignedUsersInTaskStreamProvider(task.id))
                                .valueOrNull ??
                            [];
                        return assignees.any((assignee) => assignee.id == e.id);
                      }
                    ))
                .toList() ??
            [];

      case TaskFilterOption.dueDate:
        return [
          (
            value: 'overdue',
            name: AppLocalizations.of(context)!.overdue,
            filter: (task) => task.dueDate?.isBefore(DateTime.now()) ?? false
          ),
          (
            value: 'today',
            name: AppLocalizations.of(context)!.today,
            filter: (task) => task.dueDate?.isSameDate(DateTime.now()) ?? false
          ),
          (
            value: 'thisWeek',
            name: AppLocalizations.of(context)!.thisWeek,
            filter: (task) => task.dueDate?.isSameWeek(DateTime.now()) ?? false
          ),
          (
            value: 'thisMonth',
            name: AppLocalizations.of(context)!.thisMonth,
            filter: (task) => task.dueDate?.isSameMonth(DateTime.now()) ?? false
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
                  filter: (task) => task.priority == e
                ))
            .toList();

      case TaskFilterOption.creationDate:
        return [
          (
            value: 'today',
            name: AppLocalizations.of(context)!.today,
            filter: (task) =>
                task.createdAt?.isSameDate(DateTime.now()) ?? false
          ),
          (
            value: 'thisWeek',
            name: AppLocalizations.of(context)!.thisWeek,
            filter: (task) =>
                task.createdAt?.isSameWeek(DateTime.now()) ?? false
          ),
          (
            value: 'thisMonth',
            name: AppLocalizations.of(context)!.thisMonth,
            filter: (task) =>
                task.createdAt?.isSameMonth(DateTime.now()) ?? false
          ),
          (
            value: 'customDateRange',
            name: AppLocalizations.of(context)!.customDateRange,
            filter: null
          ),
        ];
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
      };
}
