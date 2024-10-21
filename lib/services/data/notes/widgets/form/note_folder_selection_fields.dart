import 'package:seren_ai_flutter/services/data/common/widgets/form/base_project_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_team_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_folder_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_folder_states.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_viewable_projects_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_user_viewable_teams_listener_provider.dart';

class NoteFolderNameField extends BaseNameField {
  NoteFolderNameField({
    super.key,
    required super.enabled,
  }) : super(
          nameProvider:
              curNoteFolderStateProvider.select((state) => switch (state) {
                    LoadedCurNoteFolderState() =>
                      state.noteFolder.noteFolder.name,
                    _ => '',
                  }),
          updateName: (ref, name) => ref
              .read(curNoteFolderStateProvider.notifier)
              .updateNoteFolderName(name),
        );
}

class NoteFolderDescriptionField extends BaseTextBlockEditSelectionField {
  NoteFolderDescriptionField({
    super.key,
    required super.enabled,
  }) : super(
          descriptionProvider:
              curNoteFolderStateProvider.select((state) => switch (state) {
                    LoadedCurNoteFolderState() =>
                      state.noteFolder.noteFolder.description,
                    _ => null,
                  }),
          updateDescription: (ref, description) => ref
              .read(curNoteFolderStateProvider.notifier)
              .updateDescription(description),
        );
}

class NoteFolderParentProjectField extends BaseProjectSelectionField {
  NoteFolderParentProjectField({
    super.key,
    required super.enabled,
  }) : super(
          projectProvider: curNoteFolderParentProjectProvider,
          selectableProjectsProvider: curUserViewableProjectsListenerProvider,
          updateProject: (ref, project) => ref
              .read(curNoteFolderStateProvider.notifier)
              .updateParentProject(project),
        );
}

class NoteFolderParentTeamField extends BaseTeamSelectionField {
  NoteFolderParentTeamField({
    super.key,
    required super.enabled,
  }) : super(
          teamProvider: curNoteFolderParentTeamProvider,
          selectableTeamsProvider: curUserViewableTeamsListenerProvider,
          updateTeam: (ref, team) => ref
              .read(curNoteFolderStateProvider.notifier)
              .updateParentTeam(team),
        );
}
