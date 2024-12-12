import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_due_date_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_project_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_status_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_note_service_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_note_state_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';

class NoteNameField extends BaseNameField {
  NoteNameField({
    super.key,
    required super.enabled,
  }) : super(
          nameProvider: curNoteStateProvider
              .select((state) => state.value?.note.name ?? ''),
          updateName: (ref, name) =>
              ref.read(curNoteServiceProvider).updateNoteName(name),
        );
}

class NoteStatusSelectionField extends BaseStatusSelectionField {
  NoteStatusSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          statusProvider:
              curNoteStateProvider.select((state) => state.value?.note.status),
          updateStatus: (ref, status) =>
              ref.read(curNoteServiceProvider).updateStatus(status),
        );
}

class NoteDateSelectionField extends BaseDueDateSelectionField {
  NoteDateSelectionField({
    super.key,
  }) : super(
          enabled: true,
          dueDateProvider:
              curNoteStateProvider.select((state) => state.value?.note.date),
          updateDueDate: (ref, pickedDateTime) =>
              ref.read(curNoteServiceProvider).updateDate(pickedDateTime),
        );
}

class NoteDescriptionSelectionField extends BaseTextBlockEditSelectionField {
  NoteDescriptionSelectionField({
    super.key,
    required super.enabled,
    required BuildContext context,
  }) : super(
          hintText: AppLocalizations.of(context)!.description,
          descriptionProvider: curNoteStateProvider
              .select((state) => state.value?.note.description ?? ''),
          updateDescription: (ref, description) =>
              ref.read(curNoteServiceProvider).updateDescription(description),
        );
}

class NoteProjectSelectionField extends BaseProjectSelectionField {
  NoteProjectSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          projectProvider:
              curNoteStateProvider.select((state) => state.value?.project),
          selectableProjectsProvider: curUserViewableProjectsProvider,
          updateProject: (ref, project) =>
              ref.read(curNoteServiceProvider).updateParentProject(project),
          isProjectRequired: false,
        );
}

class NoteAddressSelectionField extends BaseTextBlockEditSelectionField {
  NoteAddressSelectionField({
    super.key,
    required super.enabled,
    required BuildContext context,
  }) : super(
          hintText: AppLocalizations.of(context)!.address,
          descriptionProvider: curNoteStateProvider
              .select((state) => state.value?.note.address ?? ''),
          updateDescription: (ref, address) =>
              ref.read(curNoteServiceProvider).updateAddress(address),
          labelWidget: const Icon(Icons.location_on),
        );
}

class NoteActionRequiredSelectionField extends BaseTextBlockEditSelectionField {
  NoteActionRequiredSelectionField({
    super.key,
    required BuildContext context,
    required super.enabled,
  }) : super(
          hintText: '',
          descriptionProvider: curNoteStateProvider
              .select((state) => state.value?.note.actionRequired ?? ''),
          updateDescription: (ref, actionRequired) => ref
              .read(curNoteServiceProvider)
              .updateActionRequired(actionRequired),
          labelWidget: Text(AppLocalizations.of(context)!.actionRequired),
        );
}
