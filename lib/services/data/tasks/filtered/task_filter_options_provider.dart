import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/language_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/utils/date_time_extension.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/joined_user_org_roles_by_org_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_filter.dart';
import 'package:seren_ai_flutter/services/data/users/providers/task_assigned_users_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/users/providers/user_in_project_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final taskFilterOptionsProvider =
    Provider<Map<TaskFieldEnum, List<TaskFilter>>>((ref) {
  final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
  if (projectId == null) throw Exception('No project selected');

  ref.watch(languageSNP);

  final context =
      ref.read(navigationServiceProvider).navigatorKey.currentContext!;

  final users = projectId == everythingProjectId
      ? ref
          .watch(joinedUserOrgRolesByOrgStreamProvider(
              ref.read(curSelectedOrgIdNotifierProvider)!))
          .valueOrNull
          ?.map((userOrgRole) => userOrgRole.user!)
          .toList()
      : ref.watch(usersInProjectProvider(projectId)).valueOrNull;

  return <TaskFieldEnum, List<TaskFilter>>{
    TaskFieldEnum.type: TaskType.values
        .map((type) => TaskFilter(
              field: TaskFieldEnum.type,
              value: type.name,
              readableName: type.toHumanReadable(context),
              condition: (task) => task.type == type,
            ))
        .toList(),
    TaskFieldEnum.assignees: [
      ...(users?.map((user) {
            return TaskFilter(
              field: TaskFieldEnum.assignees,
              value: user.id,
              readableName: '${user.firstName} ${user.lastName}',
              condition: (task) {
                final assignees =
                    ref.read(taskAssignedUsersStreamProvider(task.id)).value ??
                        [];
                return assignees.any((assignee) => assignee.id == user.id);
              },
            );
          }).toList() ??
          []),
      TaskFilter(
          field: TaskFieldEnum.assignees,
          value: 'none',
          readableName: AppLocalizations.of(context)!.notAssigned,
          condition: (task) =>
              ref
                  .read(taskAssignedUsersStreamProvider(task.id))
                  .value
                  ?.isEmpty ??
              true),
    ],
    TaskFieldEnum.priority: PriorityEnum.values
        .map((priority) => TaskFilter(
              field: TaskFieldEnum.priority,
              value: priority.name,
              readableName: priority.toHumanReadable(context),
              condition: (task) => task.priority == priority,
            ))
        .toList(),
    TaskFieldEnum.dueDate: [
      TaskFilter(
          field: TaskFieldEnum.dueDate,
          value: 'overdue',
          readableName: AppLocalizations.of(context)!.overdue,
          condition: (task) => task.dueDate?.isBefore(DateTime.now()) ?? false),
      TaskFilter(
          field: TaskFieldEnum.dueDate,
          value: 'today',
          readableName: AppLocalizations.of(context)!.today,
          condition: (task) =>
              task.dueDate?.isSameDate(DateTime.now()) ?? false),
      TaskFilter(
          field: TaskFieldEnum.dueDate,
          value: 'thisWeek',
          readableName: AppLocalizations.of(context)!.thisWeek,
          condition: (task) =>
              task.dueDate?.isSameWeek(DateTime.now()) ?? false),
      TaskFilter(
          field: TaskFieldEnum.dueDate,
          value: 'thisMonth',
          readableName: AppLocalizations.of(context)!.thisMonth,
          condition: (task) =>
              task.dueDate?.isSameMonth(DateTime.now()) ?? false),
      TaskFilter(
        field: TaskFieldEnum.dueDate,
        value: 'customDateRange',
        readableName: AppLocalizations.of(context)!.customDateRange,
        dateRangeCondition: (task, dateRange) =>
            (task.dueDate?.isAfter(dateRange.start) ?? false) &&
            (task.dueDate?.isBefore(dateRange.end) ?? false),
      ),
    ],
    TaskFieldEnum.createdAt: [
      TaskFilter(
          field: TaskFieldEnum.createdAt,
          value: 'today',
          readableName: AppLocalizations.of(context)!.today,
          condition: (task) =>
              task.createdAt?.isSameDate(DateTime.now()) ?? false),
      TaskFilter(
          field: TaskFieldEnum.createdAt,
          value: 'thisWeek',
          readableName: AppLocalizations.of(context)!.thisWeek,
          condition: (task) =>
              task.createdAt?.isSameWeek(DateTime.now()) ?? false),
      TaskFilter(
          field: TaskFieldEnum.createdAt,
          value: 'thisMonth',
          readableName: AppLocalizations.of(context)!.thisMonth,
          condition: (task) =>
              task.createdAt?.isSameMonth(DateTime.now()) ?? false),
      TaskFilter(
        field: TaskFieldEnum.createdAt,
        value: 'customDateRange',
        readableName: AppLocalizations.of(context)!.customDateRange,
        dateRangeCondition: (task, dateRange) =>
            (task.createdAt?.isAfter(dateRange.start) ?? false) &&
            (task.createdAt?.isBefore(dateRange.end) ?? false),
      ),
    ],
  };
});
