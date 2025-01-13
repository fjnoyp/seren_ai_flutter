import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_due_date_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_project_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_status_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_editing_note_state_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';

class NoteNameField extends BaseNameField {
  NoteNameField({
    super.key,
    required super.isEditable,
  }) : super(
          nameProvider: curEditingNoteStateProvider
              .select((state) => state.value?.noteModel.name ?? ''),
          updateName: (ref, name) => ref
              .read(curEditingNoteStateProvider.notifier)
              .updateFields(name: name),
        );
}

class NoteStatusSelectionField extends BaseStatusSelectionField {
  NoteStatusSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          statusProvider: curEditingNoteStateProvider
              .select((state) => state.value?.noteModel.status),
          updateStatus: (ref, status) => ref
              .read(curEditingNoteStateProvider.notifier)
              .updateFields(status: status),
        );
}

class NoteDateSelectionField extends BaseDueDateSelectionField {
  NoteDateSelectionField({
    super.key,
  }) : super(
          enabled: true,
          dueDateProvider: curEditingNoteStateProvider
              .select((state) => state.value?.noteModel.date),
          updateDueDate: (ref, pickedDateTime) => ref
              .read(curEditingNoteStateProvider.notifier)
              .updateFields(date: pickedDateTime),
        );
}

class NoteDescriptionSelectionField extends BaseTextBlockEditSelectionField {
  NoteDescriptionSelectionField({
    super.key,
    required super.isEditable,
    required BuildContext context,
  }) : super(
          hintText: AppLocalizations.of(context)!.description,
          descriptionProvider: curEditingNoteStateProvider
              .select((state) => state.value?.noteModel.description ?? ''),
          updateDescription: (ref, description) => ref
              .read(curEditingNoteStateProvider.notifier)
              .updateFields(description: description),
        );
}

class NoteProjectSelectionField extends BaseProjectSelectionField {
  NoteProjectSelectionField({
    super.key,
    required super.isEditable,
  }) : super(
          projectIdProvider: curEditingNoteStateProvider
              .select((state) => state.value?.noteModel.parentProjectId),
          selectableProjectsProvider: curUserViewableProjectsProvider,
          updateProject: (ref, project) => ref
              .read(curEditingNoteStateProvider.notifier)
              .updateFields(project: project),
          isProjectRequired: false,
        );
}

class NoteAddressSelectionField extends BaseTextBlockEditSelectionField {
  NoteAddressSelectionField({
    super.key,
    required super.isEditable,
    required BuildContext context,
  }) : super(
          hintText: AppLocalizations.of(context)!.address,
          descriptionProvider: curEditingNoteStateProvider
              .select((state) => state.value?.noteModel.address ?? ''),
          updateDescription: (ref, address) => ref
              .read(curEditingNoteStateProvider.notifier)
              .updateFields(address: address),
          labelWidget: const Icon(Icons.location_on),
        );
}

class NoteActionRequiredSelectionField extends BaseTextBlockEditSelectionField {
  NoteActionRequiredSelectionField({
    super.key,
    required BuildContext context,
    required super.isEditable,
  }) : super(
          hintText: '',
          descriptionProvider: curEditingNoteStateProvider
              .select((state) => state.value?.noteModel.actionRequired ?? ''),
          updateDescription: (ref, actionRequired) => ref
              .read(curEditingNoteStateProvider.notifier)
              .updateFields(actionRequired: actionRequired),
          labelWidget: Text(AppLocalizations.of(context)!.actionRequired),
        );
}
