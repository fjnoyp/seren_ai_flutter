import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/string_extensions.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_projects_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_user_team_roles_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_user_viewable_teams_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/joined_cur_user_team_roles_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_db_provider.dart';

// TODO: reduce code duplication once UI flows are confirmed 
// Combine with task_editable_field

/// A row with an icon and text that can be selected by the user.
/// Displays an editable field of a task. 
class TaskEditableMetaField extends StatelessWidget {
  final String leadText;
  final VoidCallback onPressed;
  final String text;
  final bool? hasError;

  const TaskEditableMetaField({
    Key? key,
    required this.leadText,
    required this.onPressed,
    required this.text,
    this.hasError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 80,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              leadText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: hasError ?? false ? Colors.red : null,
              ),
            ),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10),
            ),
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: hasError ?? false ? Colors.red : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
class ProjectEditableField extends HookConsumerWidget {
  final Function(String) onProjectSelected;
  final String? selectedProject;
  final bool? hasError;

  const ProjectEditableField({
    Key? key,
    required this.onProjectSelected,
    this.selectedProject,
    this.hasError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void selectProject() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ProjectSelectionModal(
            initialSelectedProject: selectedProject,
            onProjectSelected: onProjectSelected,
          );
        },
      );
    }

    String getDisplayText() {
      return selectedProject ?? 'Select Project';
    }

    return TaskEditableMetaField(
      leadText: 'Project',
      onPressed: selectProject,
      text: getDisplayText(),
      hasError: hasError,
    );
  }
}

class ProjectSelectionModal extends HookConsumerWidget {
  final String? initialSelectedProject;
  final Function(String) onProjectSelected;

  const ProjectSelectionModal({
    Key? key,
    required this.initialSelectedProject,
    required this.onProjectSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This is a placeholder. You should replace this with actual project data.
    final projects = ref.watch(curUserProjectsListenerProvider);

    if(projects == null){
      return const CircularProgressIndicator();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: projects.map((project) {
          return ListTile(
            title: Text(project.name),
            leading: Radio<String>(
              value: project.id,
              groupValue: initialSelectedProject,
              onChanged: (String? value) {
                if (value != null) {
                  onProjectSelected(value);
                  Navigator.pop(context);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TeamEditableField extends HookConsumerWidget {
  final Function(String) onTeamSelected;
  final String? selectedTeam;
  final bool? hasError;

  const TeamEditableField({
    Key? key,
    required this.onTeamSelected,
    this.selectedTeam,
    this.hasError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void selectTeam() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return TeamSelectionModal(
            initialSelectedTeam: selectedTeam,
            onTeamSelected: onTeamSelected,
          );
        },
      );
    }

    String getDisplayText() {
      return selectedTeam ?? 'Select Team';
    }

    return TaskEditableMetaField(
      leadText: 'Team',
      onPressed: selectTeam,
      text: getDisplayText(),
      hasError: hasError,
    );
  }
}

class TeamSelectionModal extends HookConsumerWidget {
  final String? initialSelectedTeam;
  final Function(String) onTeamSelected;

  const TeamSelectionModal({
    Key? key,
    required this.initialSelectedTeam,
    required this.onTeamSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This is a placeholder. You should replace this with actual team data.
    final watchedViewableTeams = ref.watch(curUserViewableTeamsListenerProvider);    

    if(watchedViewableTeams == null){
      return const CircularProgressIndicator();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: watchedViewableTeams.map((team) {
          return ListTile(
            title: Text(team.name),
            leading: Radio<String>(
              value: team.id,
              groupValue: initialSelectedTeam,
              onChanged: (String? value) {
                if (value != null) {
                  onTeamSelected(value);
                  Navigator.pop(context);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
