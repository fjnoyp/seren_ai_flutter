import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/notes/note_attachments_handler.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_read_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_states.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/delete_note_button.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/edit_note_button.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/form/note_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/pdf/share_note_button.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_attachments/note_attachment_section.dart';

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

    final curNoteState = ref.watch(curNoteStateProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Note: if the pop was triggered by the save button,
        // then result will be true, otherwise we reset the attachments
        if (mode != EditablePageMode.readOnly && didPop && result != true) {
          ref
              .read(noteAttachmentsHandlerProvider.notifier)
              .removeUnuploadedAttachments(
                  ref.read(curNoteStateProvider.notifier).curNoteId);
        }
      },
      child: switch (curNoteState) {
        LoadingCurNoteState() || InitialCurNoteState() => const Center(
            child: CircularProgressIndicator(),
          ),
        ErrorCurNoteState() => Center(child: Text(curNoteState.error)),
        LoadedCurNoteState() => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isEnabled
                      ? NoteNameField(enabled: true)
                      : Text(
                          curNoteState.joinedNote.note.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                  const SizedBox(height: 8),
                  // TODO: change together with localizations
                  if (!isEnabled)
                    Text(DateFormat.yMd()
                        .format(ref.watch(curNoteDateProvider)!)),
                  const Divider(),

                  // ======================
                  // ====== SUBITEMS ======
                  // ======================
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Column(
                      children: [
                        NoteProjectSelectionField(enabled: isEnabled),
                        const Divider(),
                        NoteDescriptionSelectionField(enabled: isEnabled),
                        const Divider(),
                        NoteAddressSelectionField(enabled: isEnabled),
                        const Divider(),
                        NoteActionRequiredSelectionField(enabled: isEnabled),
                        const Divider(),
                        NoteStatusSelectionField(enabled: isEnabled),
                        const Divider(),
                        NoteAttachmentSection(isEnabled),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (mode != EditablePageMode.readOnly)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final isValidNote = ref
                              .read(curNoteStateProvider.notifier)
                              .isValidNote();

                          if (isValidNote) {
                            if (mode == EditablePageMode.create) {
                              ref
                                  .read(curNoteStateProvider.notifier)
                                  .updateDate(DateTime.now());
                            }
                            ref.read(curNoteStateProvider.notifier).saveNote();

                            // TODO: handle error cases
                            if (context.mounted) {
                              Navigator.pop(context, true);
                            }
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

                  if (mode == EditablePageMode.readOnly)
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          openNotePage(context, ref,
                              mode: EditablePageMode.edit);
                        },
                        child: Text(AppLocalizations.of(context)!.edit)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
      },
    );
  }
}

// TODO p2: init state within the page itself ... we should only rely on arguments to init the page (to support deep linking)
Future<void> openNotePage(BuildContext context, WidgetRef ref,
    {required EditablePageMode mode,
    String? parentProjectId,
    String? noteId}) async {
  Navigator.popUntil(context, (route) => route.settings.name != notePageRoute);

  if (mode == EditablePageMode.create) {
    final curAuthUserState = ref.read(curAuthStateProvider);
    final authUser = switch (curAuthUserState) {
      LoggedInAuthState() => curAuthUserState.user,
      _ => null,
    };
    if (authUser == null) {
      throw Exception(AppLocalizations.of(context)!.userNotAuthenticated);
    }

    // TODO: verify if isn't better to use the current project id than the default one in this case
    // if (parentProjectId == null) {
    //   throw ArgumentError(
    //       AppLocalizations.of(context)!.parentProjectIdRequired);
    // }

    ref.read(curNoteStateProvider.notifier).setToNewNote();
  } else if (mode == EditablePageMode.edit ||
      mode == EditablePageMode.readOnly) {
    if (noteId != null) {
      final note = await ref.read(notesReadProvider).getItem(id: noteId);
      if (note != null) {
        ref.read(curNoteStateProvider.notifier).setNewNote(note);
      }
    }
  }

  final actions = switch (mode) {
    EditablePageMode.edit => [const DeleteNoteButton()],
    EditablePageMode.readOnly => [
        const EditNoteButton(),
        const ShareNoteButton(),
      ],
    _ => null,
  };

  await Navigator.pushNamed(context, notePageRoute,
      arguments: {'mode': mode, 'actions': actions});
}
