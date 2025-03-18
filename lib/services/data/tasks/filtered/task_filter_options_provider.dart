import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/language_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/utils/date_time_extension.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/joined_user_org_roles_by_org_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_view_type.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_filter.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/providers/task_assigned_users_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/users/providers/user_in_project_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Provides filter options based on the current view type.
/// Returns a map of filter fields to available filter options.
final taskFilterOptionsProvider =
    Provider.family<Map<TaskFieldEnum, List<TaskFilter>>, TaskFilterViewType>(
        (ref, viewType) {
  // Watch current language
  ref.watch(languageSNP);

  // Combine view-specific and common filters
  return {
    ..._getViewSpecificFilters(ref, viewType),
    ..._getCommonFilters(ref),
  };
});

/// Returns filters that are specific to a particular view type
Map<TaskFieldEnum, List<TaskFilter>> _getViewSpecificFilters(
  Ref ref,
  TaskFilterViewType viewType,
) {
  final context =
      ref.read(navigationServiceProvider).navigatorKey.currentContext!;

  switch (viewType) {
    case TaskFilterViewType.taskSearch:
      return {
        ..._createProjectFilters(ref),
        ..._createTypeFilters(context),
        ..._createAssigneesFilters(ref),
      };

    case TaskFilterViewType.projectOverview:
      final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
      if (projectId == null) throw Exception('No project selected');

      if (CurSelectedProjectIdNotifier.isEverythingId(projectId)) {
        return {
          ..._createProjectFilters(ref),
          ..._createTypeFilters(context),
          ..._createAssigneesFilters(ref),
        };
      } else {
        return {
          ..._createTypeFilters(context),
          ..._createAssigneesFilters(ref, projectId: projectId),
        };
      }

    case TaskFilterViewType.phaseSubtasks:
      final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
      if (projectId == null) throw Exception('No project selected');

      return _createAssigneesFilters(ref, projectId: projectId);
  }
}

/// Returns filters that are common to all view types
Map<TaskFieldEnum, List<TaskFilter>> _getCommonFilters(Ref ref) {
  final context =
      ref.read(navigationServiceProvider).navigatorKey.currentContext!;
  final appLocalizations = AppLocalizations.of(context)!;

  return {
    ..._createPriorityFilters(context),
    ..._createDueDateFilters(context, appLocalizations),
    ..._createCreatedAtFilters(context, appLocalizations),
  };
}

/// Creates project filter options
Map<TaskFieldEnum, List<TaskFilter>> _createProjectFilters(Ref ref) {
  final projects = ref.watch(curUserViewableProjectsProvider).valueOrNull ?? [];

  return {
    TaskFieldEnum.project: projects
        .map((project) => TaskFilter(
              field: TaskFieldEnum.project,
              value: project.id,
              readableName: project.name,
              condition: (task) => task.parentProjectId == project.id,
            ))
        .toList()
  };
}

/// Creates task type filter options
Map<TaskFieldEnum, List<TaskFilter>> _createTypeFilters(BuildContext context) {
  return {
    TaskFieldEnum.type: TaskType.values
        .map((type) => TaskFilter(
              field: TaskFieldEnum.type,
              value: type.name,
              readableName: type.toHumanReadable(context),
              condition: (task) => task.type == type,
            ))
        .toList()
  };
}

/// Creates assignee filter options
Map<TaskFieldEnum, List<TaskFilter>> _createAssigneesFilters(Ref ref,
    {String? projectId}) {
  final users = _getUsersForFilter(ref, projectId);
  final context =
      ref.read(navigationServiceProvider).navigatorKey.currentContext!;

  return {
    TaskFieldEnum.assignees: [
      ..._createUserAssigneeFilters(ref, users),
      _createUnassignedFilter(ref, context),
    ],
  };
}

/// Gets a list of users based on project context
List<UserModel> _getUsersForFilter(Ref ref, String? projectId) {
  if (projectId == null) {
    // Get org users if no project specified
    final orgId = ref.read(curSelectedOrgIdNotifierProvider);
    if (orgId == null) {
      throw Exception('No organization selected');
    }

    return ref
            .watch(joinedUserOrgRolesByOrgStreamProvider(orgId))
            .valueOrNull
            ?.map((userOrgRole) => userOrgRole.user)
            .whereType<UserModel>()
            .toList() ??
        [];
  } else {
    // Get project users
    return ref.watch(usersInProjectProvider(projectId)).valueOrNull ?? [];
  }
}

/// Creates individual user assignee filters
List<TaskFilter> _createUserAssigneeFilters(
  Ref ref,
  List<UserModel> users,
) {
  return users.map((user) {
    return TaskFilter(
      field: TaskFieldEnum.assignees,
      value: user.id,
      readableName: '${user.firstName} ${user.lastName}',
      condition: (task) {
        final assignees =
            ref.read(taskAssignedUsersStreamProvider(task.id)).value ?? [];
        return assignees.any((assignee) => assignee.id == user.id);
      },
    );
  }).toList();
}

/// Creates the "not assigned" filter
TaskFilter _createUnassignedFilter(Ref ref, BuildContext context) {
  return TaskFilter(
    field: TaskFieldEnum.assignees,
    value: 'none',
    readableName: AppLocalizations.of(context)!.notAssigned,
    condition: (task) =>
        ref.read(taskAssignedUsersStreamProvider(task.id)).value?.isEmpty ??
        true,
  );
}

/// Creates priority filter options
Map<TaskFieldEnum, List<TaskFilter>> _createPriorityFilters(
    BuildContext context) {
  return {
    TaskFieldEnum.priority: PriorityEnum.values
        .map((priority) => TaskFilter(
              field: TaskFieldEnum.priority,
              value: priority.name,
              readableName: priority.toHumanReadable(context),
              condition: (task) => task.priority == priority,
            ))
        .toList(),
  };
}

/// Creates due date filter options
Map<TaskFieldEnum, List<TaskFilter>> _createDueDateFilters(
  BuildContext context,
  AppLocalizations appLocalizations,
) {
  return {
    TaskFieldEnum.dueDate: [
      TaskFilter(
        field: TaskFieldEnum.dueDate,
        value: 'overdue',
        readableName: appLocalizations.overdue,
        condition: (task) => task.dueDate?.isBefore(DateTime.now()) ?? false,
      ),
      TaskFilter(
        field: TaskFieldEnum.dueDate,
        value: 'today',
        readableName: appLocalizations.today,
        condition: (task) => task.dueDate?.isSameDate(DateTime.now()) ?? false,
      ),
      TaskFilter(
        field: TaskFieldEnum.dueDate,
        value: 'thisWeek',
        readableName: appLocalizations.thisWeek,
        condition: (task) => task.dueDate?.isSameWeek(DateTime.now()) ?? false,
      ),
      TaskFilter(
        field: TaskFieldEnum.dueDate,
        value: 'thisMonth',
        readableName: appLocalizations.thisMonth,
        condition: (task) => task.dueDate?.isSameMonth(DateTime.now()) ?? false,
      ),
      TaskFilter(
        field: TaskFieldEnum.dueDate,
        value: 'customDateRange',
        readableName: appLocalizations.customDateRange,
        dateRangeCondition: (task, dateRange) =>
            (task.dueDate?.isAfter(dateRange.start) ?? false) &&
            (task.dueDate?.isBefore(dateRange.end) ?? false),
      ),
    ]
  };
}

/// Creates created date filter options
Map<TaskFieldEnum, List<TaskFilter>> _createCreatedAtFilters(
  BuildContext context,
  AppLocalizations appLocalizations,
) {
  return {
    TaskFieldEnum.createdAt: [
      TaskFilter(
        field: TaskFieldEnum.createdAt,
        value: 'today',
        readableName: appLocalizations.today,
        condition: (task) =>
            task.createdAt?.isSameDate(DateTime.now()) ?? false,
      ),
      TaskFilter(
        field: TaskFieldEnum.createdAt,
        value: 'thisWeek',
        readableName: appLocalizations.thisWeek,
        condition: (task) =>
            task.createdAt?.isSameWeek(DateTime.now()) ?? false,
      ),
      TaskFilter(
        field: TaskFieldEnum.createdAt,
        value: 'thisMonth',
        readableName: appLocalizations.thisMonth,
        condition: (task) =>
            task.createdAt?.isSameMonth(DateTime.now()) ?? false,
      ),
      TaskFilter(
        field: TaskFieldEnum.createdAt,
        value: 'customDateRange',
        readableName: appLocalizations.customDateRange,
        dateRangeCondition: (task, dateRange) =>
            (task.createdAt?.isAfter(dateRange.start) ?? false) &&
            (task.createdAt?.isBefore(dateRange.end) ?? false),
      ),
    ]
  };
}
