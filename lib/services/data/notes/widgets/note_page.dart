import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_read_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/form/note_selection_fields.dart';

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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NoteNameField(enabled: isEnabled),
            const SizedBox(height: 8),
            const Divider(),

            // ======================
            // ====== SUBITEMS ======
            // ======================
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                children: [
                  NoteDueDateSelectionField(enabled: isEnabled),
                  const Divider(),
                  NoteDescriptionSelectionField(enabled: isEnabled),
                  const Divider(),
                  BaseTextBlockEditSelectionField(
                    enabled: isEnabled,
                    descriptionProvider: curNoteAddressProvider,
                    updateDescription: (ref, address) => ref
                        .read(curNoteStateProvider.notifier)
                        .updateAddress(address),
                  ),
                  const Divider(),
                  BaseTextBlockEditSelectionField(
                    enabled: isEnabled,
                    descriptionProvider: curNoteActionRequiredProvider,
                    updateDescription: (ref, actionRequired) => ref
                        .read(curNoteStateProvider.notifier)
                        .updateActionRequired(actionRequired),
                  ),
                  const Divider(),
                  BaseTextBlockEditSelectionField(
                    enabled: isEnabled,
                    descriptionProvider: curNoteStatusProvider,
                    updateDescription: (ref, status) => ref
                        .read(curNoteStateProvider.notifier)
                        .updateStatus(status),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (mode != EditablePageMode.readOnly)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final isValidNote =
                        ref.read(curNoteStateProvider.notifier).isValidNote();

                    if (isValidNote) {
                      ref.read(curNoteStateProvider.notifier).saveNote();

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                  child: Text(mode == EditablePageMode.edit
                      ? 'Update Note'
                      : 'Create Note'),
                ),
              ),

            if (mode == EditablePageMode.readOnly)
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openNotePage(context, ref, mode: EditablePageMode.edit);
                  },
                  child: const Text('Edit'))
          ],
        ),
      ),
    );
  }
}

// TODO p2: init state within the page itself ... we should only rely on arguments to init the page (to support deep linking)
Future<void> openNotePage(BuildContext context, WidgetRef ref,
    {required EditablePageMode mode,
    String? parentNoteFolderId,
    String? noteId}) async {
  Navigator.popUntil(context, (route) => route.settings.name != notePageRoute);

  if (mode == EditablePageMode.create) {
    final curAuthUserState = ref.read(curAuthStateProvider);
    final authUser = switch (curAuthUserState) {
      LoggedInAuthState() => curAuthUserState.user,
      _ => null,
    };
    if (authUser == null) {
      throw Exception('Error: Current user is not authenticated.');
    }

    if (parentNoteFolderId == null) {
      throw ArgumentError(
          'Error: Parent note folder id is required for creating a note.');
    }

    // TODO p3: maybe you can select the parent folder instead in a note
    ref
        .read(curNoteStateProvider.notifier)
        .setToNewNote(authUser, parentNoteFolderId);
  } else if (mode == EditablePageMode.edit ||
      mode == EditablePageMode.readOnly) {
    if (noteId != null) {
      final note = await ref.read(notesReadProvider).getItem(id: noteId);
      if (note != null) {
        ref.read(curNoteStateProvider.notifier).setNewNote(note);
      }
    }
  }

  await Navigator.pushNamed(context, notePageRoute, arguments: {'mode': mode});
}
