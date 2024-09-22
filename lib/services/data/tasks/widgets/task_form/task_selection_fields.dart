import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_orchestrator_provider.dart';
import 'package:seren_ai_flutter/services/data/common/utils/string_extensions.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_selection_options_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/color_animation.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/ui_constants.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';

// TODO p5: consider refactoring to extend from SelectionField directly by having injectable listen for setting the current value

class TaskTeamSelectionField extends HookConsumerWidget {
  const TaskTeamSelectionField({
    super.key,
    required this.enabled,
  });

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskTeam = ref.watch(curTaskTeamProvider);
    final selectableTeams = ref.watch(curTaskSelectionOptionsProvider
        .select((state) => state.selectableTeams));

    return AnimatedModalSelectionField<TeamModel>(
      labelWidget: const SizedBox(
        width: 60,
        child: Text('Team', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      validator: (team) => team == null ? 'Team is required' : null,
      valueToString: (team) => team?.name ?? 'Select a Team',
      enabled: enabled,
      value: curTaskTeam,
      options: selectableTeams ?? [],
      onValueChanged: (ref, team) {
        ref.read(curTaskProvider.notifier).updateTeam(team);
      },
    );
  }
}


class TaskProjectSelectionField extends ConsumerWidget {
  const TaskProjectSelectionField({
    super.key,
    required this.enabled,
  });

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskProject = ref.watch(curTaskProjectProvider);
    final selectableProjects = ref.watch(curTaskSelectionOptionsProvider
        .select((state) => state.selectableProjects));

    return AnimatedModalSelectionField<ProjectModel>(
      labelWidget: const SizedBox(
        width: 60,
        child: Text('Project', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      validator: (project) => project == null ? 'Project is required' : null,
      valueToString: (project) => project?.name ?? 'Select a Project',
      enabled: enabled,
      value: curTaskProject,
      options: selectableProjects ?? [],
      onValueChanged: (ref, project) {
        ref.read(curTaskProvider.notifier).updateParentProject(project);
      },
    );
  }
}

class TaskStatusSelectionField extends ConsumerWidget {
  const TaskStatusSelectionField({
    super.key,
    required this.enabled,
  });

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskStatus =
        ref.watch(curTaskProvider.select((state) => state.task.status));

    return AnimatedModalSelectionField<StatusEnum>(
      labelWidget: const Icon(Icons.flag),
      validator: (status) => status == null ? 'Status is required' : null,
      valueToString: (status) =>
          status?.toString().enumToHumanReadable ?? 'Select Status',
      enabled: enabled,
      value: curTaskStatus,
      options: StatusEnum.values,
      onValueChanged: (ref, status) {
        ref.read(curTaskProvider.notifier).updateTask(
            ref.read(curTaskProvider).task.copyWith(status: status));
      },
    );
  }
}

class TaskPrioritySelectionField extends ConsumerWidget {
  const TaskPrioritySelectionField({
    super.key,
    required this.enabled,
  });

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskPriority =
        ref.watch(curTaskProvider.select((state) => state.task.priority));

    return AnimatedModalSelectionField<PriorityEnum>(
      labelWidget: const Icon(Icons.priority_high),
      validator: (priority) => priority == null ? 'Priority is required' : null,
      valueToString: (priority) =>
          priority?.toString().enumToHumanReadable ?? 'Select Priority',
      enabled: enabled,
      value: curTaskPriority,
      options: PriorityEnum.values,
      onValueChanged: (ref, priority) {
        ref.read(curTaskProvider.notifier).updateTask(
            ref.read(curTaskProvider).task.copyWith(priority: priority));
      },
    );
  }
}