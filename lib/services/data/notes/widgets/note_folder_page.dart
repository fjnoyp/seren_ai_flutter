import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_folder_model.dart';
import 'package:seren_ai_flutter/services/data/notes/note_folders_read_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_folder_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/form/note_folder_selection_fields.dart';

final log = Logger('NoteFolderPage');

/// For creating / editing a note folder
class NoteFolderPage extends HookConsumerWidget {
  final EditablePageMode mode;

  const NoteFolderPage({
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
            NoteFolderNameField(enabled: isEnabled),
            SizedBox(height: 8),
            Divider(),

            // ======================
            // ====== SUBITEMS ======
            // ======================
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                children: [
                  NoteFolderDescriptionField(enabled: isEnabled),
                  NoteFolderParentProjectField(enabled: isEnabled),
                  NoteFolderParentTeamField(enabled: isEnabled),
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

                    final isValidNoteFolder =
                        ref.read(curNoteFolderProvider.notifier).isValidNoteFolder();

                    // TODO p2: add validator ui - since we don't use formfield (since we use provider to manage task form state) we must manually implement validation

                    if (isValidNoteFolder) {
                      final curNoteFolder = ref.read(curNoteFolderProvider);
                      // Save note folder logic here

                      await ref.read(noteFoldersReadProvider).upsertItem(curNoteFolder.noteFolder);

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
                      ? 'Update Note Folder'
                      : 'Create Note Folder'),
                ),
              ),

            if (mode == EditablePageMode.readOnly)
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openNoteFolderPage(context, ref, mode: EditablePageMode.edit);
                  },
                  child: Text('Edit'))
          ],
        ),
      ),
    );
  }
}

// TODO p2: init state within the page itself ... we should only rely on arguments to init the page (to support deep linking)
Future<void> openNoteFolderPage(BuildContext context, WidgetRef ref,
    {required EditablePageMode mode, JoinedNoteFolderModel? joinedNoteFolder}) async {
  Navigator.popUntil(context, (route) => route.settings.name != noteFolderPageRoute);

  if (mode == EditablePageMode.create) {
    final authUser = ref.watch(curAuthUserProvider);
    if (authUser == null) {
      throw Exception('Error: Current user is not authenticated.');
    }
    ref.read(curNoteFolderProvider.notifier).setToNewNoteFolder();
  } 
  // EDIT/READ
  else if (mode == EditablePageMode.edit || mode == EditablePageMode.readOnly) {
    if (joinedNoteFolder != null) {
      ref.read(curNoteFolderProvider.notifier).setNewNoteFolder(joinedNoteFolder);
    }
  }

  await Navigator.pushNamed(context, noteFolderPageRoute,
      arguments: {'mode': mode });
}

