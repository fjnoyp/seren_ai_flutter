import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_due_date_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_project_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_status_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_states.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_viewable_projects_listener_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoteNameField extends BaseNameField {
  NoteNameField({
    super.key,
    required super.enabled,
  }) : super(
          nameProvider: curNoteStateProvider.select((state) => switch (state) {
                LoadedCurNoteState() => state.joinedNote.note.name,
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
                    LoadedCurNoteState() => state.joinedNote.note.status,
                    _ => null,
                  }),
          updateStatus: (ref, status) =>
              ref.read(curNoteStateProvider.notifier).updateStatus(status),
        );
}

class NoteDateSelectionField extends BaseDueDateSelectionField {
  NoteDateSelectionField({
    super.key,
  }) : super(
          enabled: true,
          dueDateProvider:
              curNoteStateProvider.select((state) => switch (state) {
                    LoadedCurNoteState() => state.joinedNote.note.date,
                    _ => null,
                  }),
          updateDueDate: (ref, pickedDateTime) => ref
              .read(curNoteStateProvider.notifier)
              .updateDate(pickedDateTime),
        );
}

class NoteDescriptionSelectionField extends BaseTextBlockEditSelectionField {
  NoteDescriptionSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          descriptionProvider:
              curNoteStateProvider.select((state) => switch (state) {
                    LoadedCurNoteState() => state.joinedNote.note.description,
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
          updateProject: (ref, project) => ref
              .read(curNoteStateProvider.notifier)
              .updateParentProject(project),
          isProjectRequired: false,
        );
}

class NoteAddressSelectionField extends BaseTextBlockEditSelectionField {
  NoteAddressSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          descriptionProvider: curNoteAddressProvider,
          updateDescription: (ref, address) =>
              ref.read(curNoteStateProvider.notifier).updateAddress(address),
          labelWidget: const Icon(Icons.location_on),
        );
}

class NoteActionRequiredSelectionField extends BaseTextBlockEditSelectionField {
  NoteActionRequiredSelectionField({
    super.key,
    required BuildContext context,
    required super.enabled,
  }) : super(
          descriptionProvider: curNoteActionRequiredProvider,
          updateDescription: (ref, actionRequired) => ref
              .read(curNoteStateProvider.notifier)
              .updateActionRequired(actionRequired),
          labelWidget: Text(AppLocalizations.of(context)!.actionRequired),
        );
}
