import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_read_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_states.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/delete_note_button.dart';
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

    final curNoteState = ref.watch(curNoteStateProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Note: if the pop was triggered by the save button,
        // then result will be true, otherwise we reset the attachments
        if (mode != EditablePageMode.readOnly && didPop && result != true) {
          ref.read(curNoteStateProvider.notifier).resetAttachments();
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
                  if (mode == EditablePageMode.edit)
                    // TODO: move to app bar
                    Align(
                      alignment: Alignment.topRight,
                      child: DeleteNoteButton(
                          noteId: curNoteState.joinedNote.note.id),
                    ),
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
                        NoteStatusSelectionField(enabled: isEnabled),
                        const Divider(),
                        _NoteAttachmentSection(isEnabled),
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
                            ? 'Update Note'
                            : 'Create Note'),
                      ),
                    ),

                  if (mode == EditablePageMode.readOnly)
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          openNotePage(context, ref,
                              mode: EditablePageMode.edit);
                        },
                        child: const Text('Edit'))
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
      throw Exception('Error: Current user is not authenticated.');
    }

    // TODO: verify if isn't better to use the current project id than the default one in this case
    // if (parentProjectId == null) {
    //   throw ArgumentError(
    //       'Error: Parent note folder id is required for creating a note.');
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

  await Navigator.pushNamed(context, notePageRoute, arguments: {'mode': mode});
}

class _NoteAttachmentSection extends ConsumerWidget {
  const _NoteAttachmentSection(this.isEnabled);

  final bool isEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16.0,
          children: [
            ...(ref.watch(curNoteStateProvider) as LoadedCurNoteState)
                .joinedNote
                .attachmentUrls
                .map((e) =>
                    _AttachmentPreviewButton(e, enableDelete: isEnabled)),
          ],
        ),
        if (isEnabled) const _AddAttachmentButton(),
      ],
    );
  }
}

class _AddAttachmentButton extends ConsumerWidget {
  const _AddAttachmentButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () async {
        FilePickerResult? result =
            await FilePicker.platform.pickFiles(allowMultiple: true);

        if (result != null) {
          List<File> files = result.paths.map((path) => File(path!)).toList();

          ref.read(curNoteStateProvider.notifier).uploadAttachments(files);
        }
      },
      icon: const Icon(Icons.add),
      label: const Text('Add Attachment'),
    );
  }
}

class _AttachmentPreviewButton extends StatelessWidget {
  const _AttachmentPreviewButton(
    this.attachmentUrl, {
    required this.enableDelete,
  });

  final String attachmentUrl;
  final bool enableDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => _AttachmentPreview(attachmentUrl),
          ),
          // TODO: conditionally change the icon based on its file extension
          icon: const Icon(Icons.attach_file),
          label: Text(Uri.decodeFull(attachmentUrl).split('/').last),
        ),
        if (enableDelete)
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => _DeleteAttachmentDialog(attachmentUrl),
            ),
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}

class _DeleteAttachmentDialog extends ConsumerWidget {
  const _DeleteAttachmentDialog(this.attachmentUrl);

  final String attachmentUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      content: Text('Delete ${Uri.decodeFull(attachmentUrl).split('/').last}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            ref
                .read(curNoteStateProvider.notifier)
                .deleteAttachment(attachmentUrl);
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class _AttachmentPreview extends ConsumerWidget {
  const _AttachmentPreview(
    this.attachmentUrl,
  );

  final String attachmentUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Center(
        child: switch (attachmentUrl.split('.').last) {
          'png' || 'jpg' || 'jpeg' => Image.network(
              attachmentUrl,
              loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress == null
                      ? child
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
            ),
          // TODO: add other file extensions preview
          _ => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Not able to preview this file.\n You can try opening it locally.',
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () => ref
                      .read(curNoteStateProvider.notifier)
                      .openAttachmentLocally(attachmentUrl),
                  child: const Text('Open file'),
                ),
              ],
            ),
        },
      ),
    );
  }
}
