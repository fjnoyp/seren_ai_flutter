import 'package:seren_ai_flutter/services/data/common/widgets/form/base_project_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_status_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_states.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_viewable_projects_listener_provider.dart';

class NoteNameField extends BaseNameField {
  NoteNameField({
    super.key,
    required super.enabled,
  }) : super(
          nameProvider: curNoteStateProvider.select((state) => switch (state) {
                LoadedCurNoteState() => state.note.note.name,
                _ => '',
              }),
          updateName: (ref, name) =>
              ref.read(curNoteStateProvider.notifier).updateNoteName(name),
        );
}

class NoteStatusSelectionField extends BaseStatusSelectionField {
  NoteStatusSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          statusProvider:
              curNoteStateProvider.select((state) => switch (state) {
                    LoadedCurNoteState() => state.note.note.status,
                    _ => null,
                  }),
          updateStatus: (ref, status) =>
              ref.read(curNoteStateProvider.notifier).updateStatus(status),
        );
}

class NoteDescriptionSelectionField extends BaseTextBlockEditSelectionField {
  NoteDescriptionSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          descriptionProvider:
              curNoteStateProvider.select((state) => switch (state) {
                    LoadedCurNoteState() => state.note.note.description,
                    _ => null,
                  }),
          updateDescription: (ref, description) => ref
              .read(curNoteStateProvider.notifier)
              .updateDescription(description),
        );
}

class NoteProjectSelectionField extends BaseProjectSelectionField {
  NoteProjectSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          projectProvider: curNoteProjectProvider,
          selectableProjectsProvider: curUserViewableProjectsListenerProvider,
          updateProject: (ref, project) =>
              ref.read(curNoteStateProvider.notifier).updateParentProject(project),
          isProjectRequired: false,
        );
}
