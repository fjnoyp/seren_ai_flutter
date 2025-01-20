import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_selected_note_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_attachments_service_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
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
    final isEnabled = mode != EditablePageMode.readOnly;

    final noteId = ref.watch(curSelectedNoteIdNotifierProvider);

    final note = ref.watch(noteByIdStreamProvider(noteId!));

    return AsyncValueHandlerWidget(
      value: note,
      data: (note) => note == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isEnabled
                        ? NoteNameField(noteId: noteId, isEditable: true)
                        : Text(
                            note.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                    const SizedBox(height: 8),
                    if (!isEnabled)
                      Text(DateFormat.yMd(
                              AppLocalizations.of(context)!.localeName)
                          .format(note.date!)),
                    const Divider(),

                    // ======================
                    // ====== SUBITEMS ======
                    // ======================
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        children: [
                          NoteProjectSelectionField(
                              noteId: noteId, isEditable: isEnabled),
                          const Divider(),
                          if (isEnabled) ...[
                            NoteDateSelectionField(noteId: noteId),
                            const Divider(),
                          ],
                          NoteDescriptionSelectionField(
                            noteId: noteId,
                            isEditable: isEnabled,
                            context: context,
                          ),
                          const Divider(),
                          NoteAddressSelectionField(
                            noteId: noteId,
                            isEditable: isEnabled,
                            context: context,
                          ),
                          const Divider(),
                          NoteActionRequiredSelectionField(
                            noteId: noteId,
                            isEditable: isEnabled,
                            context: context,
                          ),
                          const Divider(),
                          NoteStatusSelectionField(
                            noteId: noteId,
                            enabled: isEnabled,
                          ),
                          const Divider(),
                          NoteAttachmentSection(
                            isEnabled,
                            noteId: noteId,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}

// TODO p2: init state within the page itself ... we should only rely on arguments to init the page (to support deep linking)
Future<void> openNotePage(
  BuildContext context,
  WidgetRef ref, {
  required EditablePageMode mode,
  String? initialNoteId,
}) async {
  ref
      .read(navigationServiceProvider)
      .popUntil((route) => route.settings.name != AppRoutes.notePage.name);

  if (initialNoteId != null) {
    ref
        .read(curSelectedNoteIdNotifierProvider.notifier)
        .setNoteId(initialNoteId);
  }

  final noteId = initialNoteId ?? ref.read(curSelectedNoteIdNotifierProvider)!;

  ref
      .read(noteAttachmentsServiceProvider.notifier)
      .fetchNoteAttachments(noteId: noteId);

  final actions = switch (mode) {
    EditablePageMode.edit => [DeleteNoteButton(noteId)],
    EditablePageMode.readOnly => [
        EditNoteButton(noteId),
        ShareNoteButton(noteId),
      ],
    _ => null,
  };

  final title = switch (mode) {
    EditablePageMode.edit => AppLocalizations.of(context)!.updateNote,
    // if mode is readOnly, we assume task state is loaded
    EditablePageMode.readOnly => await ref
            .read(notesRepositoryProvider)
            .getById(noteId)
            .then((note) => note?.name) ??
        '',
    // we don't handle create mode here because it is handled in openNewTaskPage
    // which is called in the beginning of this method
    _ => '',
  };

  await ref.read(navigationServiceProvider).navigateTo(
    AppRoutes.notePage.name,
    arguments: {'mode': mode, 'actions': actions, 'title': title},
    // invalidate the note attachments service provider to clear the attachments state
  ).then((_) => ref.invalidate(noteAttachmentsServiceProvider));
}

Future<void> openNewNotePage(
  BuildContext context,
  WidgetRef ref, {
  String? parentProjectId,
}) async {
  ref
      .read(navigationServiceProvider)
      .popUntil((route) => route.settings.name != AppRoutes.notePage.name);

  await ref
      .read(curSelectedNoteIdNotifierProvider.notifier)
      .createNewNote(parentProjectId: parentProjectId);

  final noteId = ref.watch(curSelectedNoteIdNotifierProvider)!;

  final actions = [DeleteNoteButton(noteId)];

  final title = AppLocalizations.of(context)!.createNote;

  await ref.read(navigationServiceProvider).navigateTo(
    AppRoutes.notePage.name,
    arguments: {
      'mode': EditablePageMode.create,
      'actions': actions,
      'title': title,
    },
  );
}
