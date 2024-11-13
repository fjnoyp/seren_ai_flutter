import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_note_service_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_note_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_attachments_service_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/joined_notes_repository.dart';
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

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Note: if the pop was triggered by the save button,
        // then result will be true, otherwise we reset the attachments
        if (mode != EditablePageMode.readOnly && didPop && result != true) {
          ref
              .read(noteAttachmentsServiceProvider.notifier)
              .removeUnuploadedAttachments(
                  ref.read(curNoteServiceProvider).curNoteId);
        }
      },
      child: AsyncValueHandlerWidget(
        value: ref.watch(curNoteStateProvider),
        data: (joinedNote) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isEnabled
                    ? NoteNameField(enabled: true)
                    : Text(
                        joinedNote!.note.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                const SizedBox(height: 8),
                if (!isEnabled)
                  Text(DateFormat.yMd(AppLocalizations.of(context)!.localeName)
                      .format(joinedNote!.note.date!)),
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
                      if (isEnabled) ...[
                        NoteDateSelectionField(),
                        const Divider(),
                      ],
                      NoteDescriptionSelectionField(enabled: isEnabled),
                      const Divider(),
                      NoteAddressSelectionField(enabled: isEnabled),
                      const Divider(),
                      NoteActionRequiredSelectionField(
                        enabled: isEnabled,
                        context: context,
                      ),
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
                      onPressed: () {
                        ref.read(curNoteServiceProvider).saveNote();

                        // TODO p4: handle error cases
                        if (context.mounted) {
                          Navigator.pop(context, true);
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
  Navigator.popUntil(context, (route) => route.settings.name != AppRoutes.notePage.name);

  if (mode == EditablePageMode.create) {
    ref.read(curNoteServiceProvider).createNote(
          parentProjectId: parentProjectId,
        );
  } else if (mode == EditablePageMode.edit ||
      mode == EditablePageMode.readOnly) {
    if (noteId != null) {
      final note = await ref
          .read(joinedNotesRepositoryProvider)
          .getJoinedNote(noteId);
      ref.read(curNoteServiceProvider).loadNote(note);
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

  await Navigator.pushNamed(context, AppRoutes.notePage.name,
      arguments: {'mode': mode, 'actions': actions});
}
