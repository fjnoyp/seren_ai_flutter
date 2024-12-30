import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/utils/date_time_extension.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/selected_project_service_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/users/providers/users_in_project_provider.dart';

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

  List<({String value, String name, bool Function(JoinedTaskModel)? filter})>
      getSubOptions(BuildContext context, WidgetRef ref) {
    switch (this) {
      case TaskFilterOption.assignees:
        return ref
                .watch(usersInProjectProvider(ref
                    .watch(selectedProjectServiceProvider)
                    .value!
                    .project
                    .id))
                .value
                ?.map((e) => (
                      value: e.id,
                      name: '${e.firstName} ${e.lastName}',
                      filter: (JoinedTaskModel task) =>
                          task.assignees.any((assignee) => assignee.id == e.id)
                    ))
                .toList() ??
            [];

      case TaskFilterOption.dueDate:
        return [
          (
            value: 'overdue',
            name: AppLocalizations.of(context)!.overdue,
            filter: (task) => task.task.dueDate!.isBefore(DateTime.now())
          ),
          (
            value: 'today',
            name: AppLocalizations.of(context)!.today,
            filter: (task) => task.task.dueDate!.isSameDate(DateTime.now())
          ),
          (
            value: 'thisWeek',
            name: AppLocalizations.of(context)!.thisWeek,
            filter: (task) => task.task.dueDate!.isSameWeek(DateTime.now())
          ),
          (
            value: 'thisMonth',
            name: AppLocalizations.of(context)!.thisMonth,
            filter: (task) => task.task.dueDate!.isSameMonth(DateTime.now())
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
                  filter: (task) => task.task.priority == e
                ))
            .toList();

      case TaskFilterOption.creationDate:
        return [
          (
            value: 'today',
            name: AppLocalizations.of(context)!.today,
            filter: (task) => task.task.createdAt!.isSameDate(DateTime.now())
          ),
          (
            value: 'thisWeek',
            name: AppLocalizations.of(context)!.thisWeek,
            filter: (task) => task.task.createdAt!.isSameWeek(DateTime.now())
          ),
          (
            value: 'thisMonth',
            name: AppLocalizations.of(context)!.thisMonth,
            filter: (task) => task.task.createdAt!.isSameMonth(DateTime.now())
          ),
          (
            value: 'customDateRange',
            name: AppLocalizations.of(context)!.customDateRange,
            filter: null
          ),
        ];
    }
  }

  bool Function(JoinedTaskModel, DateTimeRange?) get filterFunction =>
      switch (this) {
        TaskFilterOption.assignees => (task, _) => true,
        TaskFilterOption.dueDate => (task, dateRange) => dateRange != null
            ? task.task.dueDate!.isAfter(dateRange.start) &&
                task.task.dueDate!.isBefore(dateRange.end)
            : true,
        TaskFilterOption.priority => (task, _) => true,
        TaskFilterOption.creationDate => (task, dateRange) => dateRange != null
            ? task.task.createdAt!.isAfter(dateRange.start) &&
                task.task.createdAt!.isBefore(dateRange.end)
            : true,
      };
}
