import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_selected_note_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/delete_note_button.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/form/note_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_attachments/note_attachment_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final log = Logger('NotePage');

/// For creating / editing a note
class NotePage extends HookConsumerWidget {
  final EditablePageMode mode;

  const NotePage({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteId = ref.watch(curSelectedNoteIdNotifierProvider)!;
    final note = ref.watch(noteByIdStreamProvider(noteId));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                isWebVersion
                    ? IconButton(
                        onPressed: () =>
                            ref.read(navigationServiceProvider).pop(true),
                        icon: const Icon(Icons.close),
                      )
                    : const Expanded(child: SizedBox.shrink()),
                const SizedBox(width: 32),
                Text(
                  note.isReloading
                      ? AppLocalizations.of(context)!.saving
                      : note.hasError
                          ? AppLocalizations.of(context)!.errorSaving
                          : AppLocalizations.of(context)!.allChangesSaved,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            NoteNameField(noteId: noteId),
            const SizedBox(height: 8),
            const Divider(),

            // ======================
            // ====== SUBITEMS ======
            // ======================
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                children: [
                  NoteProjectSelectionField(noteId: noteId),
                  const Divider(),
                  NoteDateSelectionField(noteId: noteId),
                  const Divider(),
                  NoteDescriptionSelectionField(
                    noteId: noteId,
                    context: context,
                  ),
                  const Divider(),
                  NoteAddressSelectionField(noteId: noteId, context: context),
                  const Divider(),
                  NoteActionRequiredSelectionField(
                    noteId: noteId,
                    context: context,
                  ),
                  const Divider(),
                  NoteStatusSelectionField(noteId: noteId),
                  const Divider(),
                  NoteAttachmentSection(noteId: noteId),
                ],
              ),
            ),

            if (mode == EditablePageMode.create && !isWebVersion)
              PopScope(
                onPopInvokedWithResult: (_, result) async {
                  if (result != true) {
                    final curNoteId =
                        ref.read(curSelectedNoteIdNotifierProvider)!;
                    ref
                        .read(curSelectedNoteIdNotifierProvider.notifier)
                        .clearNoteId();
                    ref.read(notesRepositoryProvider).deleteItem(curNoteId);
                  }
                },
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(navigationServiceProvider).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                    ),
                    child: Text(AppLocalizations.of(context)!.createNote),
                  ),
                ),
              ),

            if (isWebVersion) DeleteNoteButton(noteId, showLabelText: true),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
