import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/language_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/utils/date_time_extension.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
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

/// Predefined task filters for status
class TFStatus {
  /// Filter for tasks by status
  static TaskFilter byStatus(BuildContext context, StatusEnum status) =>
      TaskFilter(
        field: TaskFieldEnum.status,
        readableName: status.toHumanReadable(context),
        condition: (task) => task.status == status,
      );

  /// Filter for tasks by status string
  static TaskFilter status(BuildContext context, String statusStr) {
    final status = StatusEnum.tryParse(statusStr);
    return TaskFilter(
      field: TaskFieldEnum.status,
      readableName: status.toHumanReadable(context),
      condition: (task) => task.status == status,
    );
  }
}

/// Predefined task filters for due dates
class TFDueDate {
  /// Filter for overdue tasks
  static TaskFilter overdue(BuildContext context) => TaskFilter(
        field: TaskFieldEnum.dueDate,
        readableName: AppLocalizations.of(context)!.overdue,
        condition: (task) =>
            (task.dueDate?.isBefore(DateTime.now()) ?? false) &&
            task.status != StatusEnum.finished,
      );

  /// Filter for tasks due today
  static TaskFilter today(BuildContext context) => TaskFilter(
        field: TaskFieldEnum.dueDate,
        readableName: AppLocalizations.of(context)!.today,
        condition: (task) => task.dueDate?.isSameDate(DateTime.now()) ?? false,
      );

  /// Filter for tasks due this week
  static TaskFilter thisWeek(BuildContext context) => TaskFilter(
        field: TaskFieldEnum.dueDate,
        readableName: AppLocalizations.of(context)!.thisWeek,
        condition: (task) => task.dueDate?.isSameWeek(DateTime.now()) ?? false,
      );

  /// Filter for tasks due this month
  static TaskFilter thisMonth(BuildContext context) => TaskFilter(
        field: TaskFieldEnum.dueDate,
        readableName: AppLocalizations.of(context)!.thisMonth,
        condition: (task) => task.dueDate?.isSameMonth(DateTime.now()) ?? false,
      );

  /// Filter for tasks due in a custom date range
  static TaskFilter customDateRange(BuildContext context) => TaskFilter(
        field: TaskFieldEnum.dueDate,
        showDateRangePicker: true,
        readableName: AppLocalizations.of(context)!.customDateRange,
        condition: (task) => true,
        // dateRangeCondition: (task, dateRange) =>
        //     (task.dueDate?.isAfter(dateRange.start) ?? false) &&
        //     (task.dueDate?.isBefore(dateRange.end) ?? false),
      );
}

/// Predefined task filters for created date
class TFCreatedAt {
  /// Filter for tasks created today
  static TaskFilter today(BuildContext context) => TaskFilter(
        field: TaskFieldEnum.createdAt,
        readableName: AppLocalizations.of(context)!.today,
        condition: (task) =>
            task.createdAt?.isSameDate(DateTime.now()) ?? false,
      );

  /// Filter for tasks created this week
  static TaskFilter thisWeek(BuildContext context) => TaskFilter(
        field: TaskFieldEnum.createdAt,
        readableName: AppLocalizations.of(context)!.thisWeek,
        condition: (task) =>
            task.createdAt?.isSameWeek(DateTime.now()) ?? false,
      );

  /// Filter for tasks created this month
  static TaskFilter thisMonth(BuildContext context) => TaskFilter(
        field: TaskFieldEnum.createdAt,
        readableName: AppLocalizations.of(context)!.thisMonth,
        condition: (task) =>
            task.createdAt?.isSameMonth(DateTime.now()) ?? false,
      );

  /// Filter for tasks created in a custom date range
  static TaskFilter customDateRange(BuildContext context) => TaskFilter(
        field: TaskFieldEnum.createdAt,
        showDateRangePicker: true,
        readableName: AppLocalizations.of(context)!.customDateRange,
        // This must be overrided in the filter view
        condition: (task) => true,
        // dateRangeCondition: (task, dateRange) =>
        //     (task.createdAt?.isAfter(dateRange.start) ?? false) &&
        //     (task.createdAt?.isBefore(dateRange.end) ?? false),
      );
}

/// Predefined task filters for priority
class TFPriority {
  /// Filter for tasks by priority
  static TaskFilter byPriority(BuildContext context, PriorityEnum priority) =>
      TaskFilter(
        field: TaskFieldEnum.priority,
        readableName: priority.toHumanReadable(context),
        condition: (task) => task.priority == priority,
      );

  /// Filter for tasks by priority string
  static TaskFilter priority(BuildContext context, String priorityStr) {
    final priority = PriorityEnum.tryParse(priorityStr);
    return TaskFilter(
      field: TaskFieldEnum.priority,
      readableName: priority.toHumanReadable(context),
      condition: (task) => task.priority == priority,
    );
  }
}

/// Predefined task filters for task type
class TFType {
  /// Filter for tasks by type
  static TaskFilter byType(BuildContext context, TaskType type) => TaskFilter(
        field: TaskFieldEnum.type,
        readableName: type.toHumanReadable(context),
        condition: (task) => task.type == type,
      );
}

/// Predefined task filters for assignees
class TFAssignees {
  /// Filter for tasks assigned to a specific user
  static TaskFilter byUser(Ref ref,
          {required String userId,
          required String firstName,
          required String lastName}) =>
      TaskFilter(
        field: TaskFieldEnum.assignees,
        readableName: '$firstName $lastName',
        condition: (task) {
          // TODO p1: we shouldn't be "reading" the stream here
          // this is likely causing not all matching tasks to be shown
          final assignees =
              ref.read(taskAssignedUsersStreamProvider(task.id)).value ?? [];
          return assignees.any((assignee) => assignee.id == userId);
        },
      );

  static TaskFilter byUserModel(Ref ref, UserModel user) => TFAssignees.byUser(
        ref,
        userId: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
      );

  /// Filter for unassigned tasks
  static TaskFilter unassigned(Ref ref, BuildContext context) => TaskFilter(
        field: TaskFieldEnum.assignees,
        readableName: AppLocalizations.of(context)!.notAssigned,
        condition: (task) {
          // TODO p1: we shouldn't be "reading" the stream here
          final assignees =
              ref.read(taskAssignedUsersStreamProvider(task.id)).value ?? [];
          return assignees.isEmpty;
        },
      );
}

/// Predefined task filters for author user
class TFAuthorUser {
  /// Filter for tasks by author user
  static TaskFilter byUser(Ref ref,
          {required String userId,
          required String firstName,
          required String lastName}) =>
      TaskFilter(
        field: TaskFieldEnum.author,
        readableName: '$firstName $lastName',
        condition: (task) => task.authorUserId == userId,
      );

  static TaskFilter byUserModel(Ref ref, UserModel user) => TFAuthorUser.byUser(
        ref,
        userId: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
      );
}

/// Predefined task filters for projects
class TFProject {
  /// Filter for tasks in a specific project
  static TaskFilter byProject(
          {required String projectId, required String projectName}) =>
      TaskFilter(
        field: TaskFieldEnum.project,
        readableName: projectName,
        condition: (task) => task.parentProjectId == projectId,
      );
}

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
    case TaskFilterViewType.modalSearch:
      return {
        ..._createProjectFilters(ref),
        ..._createTypeFilters(context),
        ..._createAuthorUserFilters(ref),
        ..._createAssigneesFilters(ref),
      };

    case TaskFilterViewType.projectOverview:
      final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
      if (projectId == null) throw Exception('No project selected');

      if (CurSelectedProjectIdNotifier.isEverythingId(projectId)) {
        return {
          ..._createProjectFilters(ref),
          ..._createTypeFilters(context),
          ..._createAuthorUserFilters(ref),
          ..._createAssigneesFilters(ref),
        };
      } else {
        return {
          ..._createTypeFilters(context),
          ..._createAuthorUserFilters(ref, projectId: projectId),
          ..._createAssigneesFilters(ref, projectId: projectId),
        };
      }

    case TaskFilterViewType.phaseSubtasks:
      final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
      if (projectId == null) throw Exception('No project selected');

      return {
        ..._createAuthorUserFilters(ref, projectId: projectId),
        ..._createAssigneesFilters(ref, projectId: projectId),
      };
  }
}

/// Returns filters that are common to all view types
Map<TaskFieldEnum, List<TaskFilter>> _getCommonFilters(Ref ref) {
  final context =
      ref.read(navigationServiceProvider).navigatorKey.currentContext!;
  final appLocalizations = AppLocalizations.of(context)!;

  return {
    ..._createStatusFilters(context),
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
        .map((project) => TFProject.byProject(
            projectId: project.id, projectName: project.name))
        .toList()
  };
}

/// Creates task type filter options
Map<TaskFieldEnum, List<TaskFilter>> _createTypeFilters(BuildContext context) {
  return {
    TaskFieldEnum.type:
        TaskType.values.map((type) => TFType.byType(context, type)).toList()
  };
}

/// Creates status filter options
Map<TaskFieldEnum, List<TaskFilter>> _createStatusFilters(
    BuildContext context) {
  return {
    TaskFieldEnum.status: StatusEnum.values
        .map((status) => TFStatus.byStatus(context, status))
        .toList(),
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
      TFAssignees.unassigned(ref, context),
    ],
  };
}

/// Creates author user filter options
Map<TaskFieldEnum, List<TaskFilter>> _createAuthorUserFilters(Ref ref,
    {String? projectId}) {
  final users = _getUsersForFilter(ref, projectId);

  return {
    TaskFieldEnum.author: [
      ...users.map((user) => TFAuthorUser.byUserModel(ref, user)),
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
  return users.map((user) => TFAssignees.byUserModel(ref, user)).toList();
}

/// Creates priority filter options
Map<TaskFieldEnum, List<TaskFilter>> _createPriorityFilters(
    BuildContext context) {
  return {
    TaskFieldEnum.priority: PriorityEnum.values
        .map((priority) => TFPriority.byPriority(context, priority))
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
      TFDueDate.overdue(context),
      TFDueDate.today(context),
      TFDueDate.thisWeek(context),
      TFDueDate.thisMonth(context),
      TFDueDate.customDateRange(context),
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
      TFCreatedAt.today(context),
      TFCreatedAt.thisWeek(context),
      TFCreatedAt.thisMonth(context),
      TFCreatedAt.customDateRange(context),
    ]
  };
}
