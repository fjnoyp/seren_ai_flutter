import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_due_date_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_states.dart';

class NoteNameField extends BaseNameField {
  NoteNameField({
    super.key,
    required super.enabled,
  }) : super(
          nameProvider: curNoteProvider.select((state) => switch (state) {
                LoadedCurNoteState() => state.note.name,
                _ => '',
              }),
          updateName: (ref, name) =>
              ref.read(curNoteProvider.notifier).updateNoteName(name),
        );
}

class NoteDueDateSelectionField extends BaseDueDateSelectionField {
  NoteDueDateSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          dueDateProvider: curNoteProvider.select((state) => switch (state) {
                LoadedCurNoteState() => state.note.date,
                _ => null,
              }),
          pickAndUpdateDueDate: (ref, context) =>
              ref.read(curNoteProvider.notifier).pickAndUpdateDate(context),
        );
}

class NoteDescriptionSelectionField extends BaseTextBlockEditSelectionField {
 NoteDescriptionSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          descriptionProvider: curNoteProvider.select((state) => switch (state) {
                LoadedCurNoteState() => state.note.description,
                _ => null,
              }),
          updateDescription: (ref, description) =>
              ref.read(curNoteProvider.notifier).updateDescription(description),
        );
}
