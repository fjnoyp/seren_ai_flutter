import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_description_selection_field.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_read_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/form/note_selection_fields.dart';

final log = Logger('NotePage');

/// For creating / editing a note
class NotePage extends HookConsumerWidget {
  final EditablePageMode mode;
  final String? noteId;

  const NotePage({
    super.key,
    required this.mode,
    this.noteId,
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
            SizedBox(height: 8),
            Divider(),

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
                    updateDescription: (ref, address) =>
                        ref.read(curNoteProvider.notifier).updateAddress(address),
                  ),
                  const Divider(),
                  BaseTextBlockEditSelectionField(
                    enabled: isEnabled,
                    descriptionProvider: curNoteActionRequiredProvider,
                    updateDescription: (ref, actionRequired) =>
                        ref.read(curNoteProvider.notifier).updateActionRequired(actionRequired),
                  ),
                  const Divider(),
                  BaseTextBlockEditSelectionField(
                    enabled: isEnabled,
                    descriptionProvider: curNoteStatusProvider,
                    updateDescription: (ref, status) =>
                        ref.read(curNoteProvider.notifier).updateStatus(status),
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
                    final curAuthUser = ref.watch(curAuthUserProvider);

                    if (curAuthUser == null) {
                      log.severe('Error: Current user is not authenticated.');
                      return;
                    }

                    final isValidNote =
                        ref.read(curNoteProvider.notifier).isValidNote();

                    if (isValidNote) {
                      final curNote = ref.read(curNoteProvider);
                      // Save note logic here

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
                    openNotePage(context, ref, mode: EditablePageMode.edit, noteId: noteId);
                  },
                  child: Text('Edit'))
          ],
        ),
      ),
    );
  }
}

Future<void> openBlankNotePage(BuildContext context, Ref ref) async {
  Navigator.popUntil(context, (route) => route.settings.name != notePageRoute);

  final authUser = ref.watch(curAuthUserProvider);
  if (authUser == null) {
    throw Exception('Error: Current user is not authenticated.');
  }
  ref.read(curNoteProvider.notifier).setToNewNote(authUser);

  await Navigator.pushNamed(context, notePageRoute,
      arguments: {'mode': EditablePageMode.create});
}

Future<void> openNotePage(BuildContext context, WidgetRef ref,
    {required EditablePageMode mode, String? noteId}) async {
  Navigator.popUntil(context, (route) => route.settings.name != notePageRoute);

  if (mode == EditablePageMode.create) {
    final authUser = ref.watch(curAuthUserProvider);
    if (authUser == null) {
      throw Exception('Error: Current user is not authenticated.');
    }
    ref.read(curNoteProvider.notifier).setToNewNote(authUser);
  } else if (mode == EditablePageMode.edit || mode == EditablePageMode.readOnly) {
    if (noteId != null) {
      final note = await ref.read(notesReadProvider).getItem(id: noteId);
      if (note != null) {
        ref.read(curNoteProvider.notifier).setNewNote(note);
      }
    }
  }

  await Navigator.pushNamed(context, notePageRoute,
      arguments: {'mode': mode, 'noteId': noteId});
}
