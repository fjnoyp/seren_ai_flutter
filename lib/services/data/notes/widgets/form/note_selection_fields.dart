import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_date_time_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_project_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_status_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';

class NoteNameField extends BaseNameField {
  final String noteId;

  NoteNameField({
    super.key,
    required super.isEditable,
    required this.noteId,
  }) : super(
          nameProvider: noteByIdStreamProvider(noteId)
              .select((note) => note.value?.name ?? ''),
          updateName: (ref, name) =>
              ref.read(notesRepositoryProvider).updateNoteName(noteId, name),
        );
}

class NoteStatusSelectionField extends BaseStatusSelectionField {
  final String noteId;

  NoteStatusSelectionField({
    super.key,
    required super.enabled,
    required this.noteId,
  }) : super(
          statusProvider: noteByIdStreamProvider(noteId)
              .select((note) => note.value?.status),
          updateStatus: (ref, status) => ref
              .read(notesRepositoryProvider)
              .updateNoteStatus(noteId, status),
        );
}

class NoteDateSelectionField extends BaseDueDateSelectionField {
  final String noteId;

  NoteDateSelectionField({
    super.key,
    required this.noteId,
  }) : super(
          enabled: true,
          dueDateProvider:
              noteByIdStreamProvider(noteId).select((note) => note.value?.date),
          updateDueDate: (ref, pickedDateTime) => ref
              .read(notesRepositoryProvider)
              .updateNoteDate(noteId, pickedDateTime),
        );
}

class NoteDescriptionSelectionField extends BaseTextBlockEditSelectionField {
  final String noteId;

  NoteDescriptionSelectionField({
    super.key,
    required super.isEditable,
    required this.noteId,
    required BuildContext context,
  }) : super(
          hintText: AppLocalizations.of(context)!.description,
          descriptionProvider: noteByIdStreamProvider(noteId)
              .select((note) => note.value?.description ?? ''),
          updateDescription: (ref, description) => ref
              .read(notesRepositoryProvider)
              .updateNoteDescription(noteId, description),
        );
}

class NoteProjectSelectionField extends BaseProjectSelectionField {
  final String noteId;

  NoteProjectSelectionField({
    super.key,
    required super.isEditable,
    required this.noteId,
  }) : super(
          projectIdProvider: noteByIdStreamProvider(noteId)
              .select((note) => note.value?.parentProjectId),
          selectableProjectsProvider: curUserViewableProjectsProvider,
          updateProject: (ref, project) => ref
              .read(notesRepositoryProvider)
              .updateNoteParentProjectId(noteId, project?.id),
          isProjectRequired: false,
        );
}

class NoteAddressSelectionField extends BaseTextBlockEditSelectionField {
  final String noteId;

  NoteAddressSelectionField({
    super.key,
    required super.isEditable,
    required this.noteId,
    required BuildContext context,
  }) : super(
          hintText: AppLocalizations.of(context)!.address,
          descriptionProvider: noteByIdStreamProvider(noteId)
              .select((note) => note.value?.address ?? ''),
          updateDescription: (ref, address) => ref
              .read(notesRepositoryProvider)
              .updateNoteAddress(noteId, address),
          labelWidget: const Icon(Icons.location_on),
        );
}

class NoteActionRequiredSelectionField extends BaseTextBlockEditSelectionField {
  final String noteId;

  NoteActionRequiredSelectionField({
    super.key,
    required BuildContext context,
    required super.isEditable,
    required this.noteId,
  }) : super(
          hintText: '',
          descriptionProvider: noteByIdStreamProvider(noteId)
              .select((note) => note.value?.actionRequired ?? ''),
          updateDescription: (ref, actionRequired) => ref
              .read(notesRepositoryProvider)
              .updateNoteActionRequired(noteId, actionRequired),
          labelWidget: Text(AppLocalizations.of(context)!.actionRequired),
        );
}
