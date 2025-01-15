import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_editing_note_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_attachments_service_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/delete_note_button.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/edit_note_button.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/form/note_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/pdf/share_note_button.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_attachments/note_attachment_section.dart';
import 'package:seren_ai_flutter/common/is_show_save_dialog_on_pop_provider.dart';

final log = Logger('NotePage');

/// For creating / editing a note
class NotePage extends HookConsumerWidget {
  final EditablePageMode mode;

  const NotePage({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final isEnabled = mode != EditablePageMode.readOnly;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Note: if the pop was triggered by the save button,
        // then result will be true, otherwise we reset the attachments
        if (mode != EditablePageMode.readOnly && didPop && result != true) {
          ref
              .read(noteAttachmentsServiceProvider.notifier)
              .removeUnuploadedAttachments(
                  ref.read(curEditingNoteStateProvider.notifier).curNoteId);
        }
      },
      child: AsyncValueHandlerWidget(
        value: ref.watch(curEditingNoteStateProvider),
        data: (state) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isEnabled
                    ? NoteNameField(isEditable: true)
                    : Text(
                        state.noteModel.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                const SizedBox(height: 8),
                if (!isEnabled)
                  Text(DateFormat.yMd(AppLocalizations.of(context)!.localeName)
                      .format(state.noteModel.date!)),
                const Divider(),

                // ======================
                // ====== SUBITEMS ======
                // ======================
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Column(
                    children: [
                      NoteProjectSelectionField(isEditable: isEnabled),
                      const Divider(),
                      if (isEnabled) ...[
                        NoteDateSelectionField(),
                        const Divider(),
                      ],
                      NoteDescriptionSelectionField(
                        isEditable: isEnabled,
                        context: context,
                      ),
                      const Divider(),
                      NoteAddressSelectionField(
                        isEditable: isEnabled,
                        context: context,
                      ),
                      const Divider(),
                      NoteActionRequiredSelectionField(
                        isEditable: isEnabled,
                        context: context,
                      ),
                      const Divider(),
                      NoteStatusSelectionField(enabled: isEnabled),
                      const Divider(),
                      NoteAttachmentSection(
                        isEnabled,
                        noteId: state.noteModel.id,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (mode != EditablePageMode.readOnly)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(curEditingNoteStateProvider.notifier)
                            .saveChanges();

                        // TODO p4: handle error cases
                        if (context.mounted) {
                          ref
                              .read(isShowSaveDialogOnPopProvider.notifier)
                              .reset();
                          ref.read(navigationServiceProvider).pop(true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                      ),
                      child: Text(mode == EditablePageMode.edit
                          ? AppLocalizations.of(context)!.updateNote
                          : AppLocalizations.of(context)!.createNote),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// TODO p2: init state within the page itself ... we should only rely on arguments to init the page (to support deep linking)
Future<void> openNotePage(BuildContext context, WidgetRef ref,
    {required EditablePageMode mode,
    String? parentProjectId,
    String? noteId}) async {
  ref
      .read(navigationServiceProvider)
      .popUntil((route) => route.settings.name != AppRoutes.notePage.name);

  if (mode == EditablePageMode.create) {
    ref.read(curEditingNoteStateProvider.notifier).createNewNote(
          parentProjectId: parentProjectId,
        );
  } else if (mode == EditablePageMode.edit ||
      mode == EditablePageMode.readOnly) {
    if (noteId != null) {
      final note = await ref.read(notesRepositoryProvider).getById(noteId);
      if (note != null) {
        await ref.read(curEditingNoteStateProvider.notifier).loadNote(note);
      }
    }
  }

  final actions = switch (mode) {
    EditablePageMode.edit => [const DeleteNoteButton()],
    EditablePageMode.readOnly => [
        // TODO p3: note should not be implicit, we should be directly passing down which note should be affected here by using the notes retrieved from above ... current code can cause issues if the note is not the current note
        const EditNoteButton(),
        const ShareNoteButton(),
      ],
    _ => null,
  };

  final title = switch (mode) {
    EditablePageMode.edit => AppLocalizations.of(context)!.updateNote,
    EditablePageMode.create => AppLocalizations.of(context)!.createNote,
    // if mode is readOnly, we assume task state is loaded
    EditablePageMode.readOnly =>
      ref.read(curEditingNoteStateProvider).value!.noteModel.name,
  };

  if (mode == EditablePageMode.edit || mode == EditablePageMode.create) {
    ref.read(isShowSaveDialogOnPopProvider.notifier).setCanSave(true);
  }

  await ref.read(navigationServiceProvider).navigateTo(AppRoutes.notePage.name,
      arguments: {'mode': mode, 'actions': actions, 'title': title});
}
