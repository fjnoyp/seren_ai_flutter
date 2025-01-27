import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_selected_note_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_attachments_service_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/delete_note_button.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/pdf/share_note_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final notesNavigationServiceProvider = Provider<NotesNavigationService>((ref) {
  return NotesNavigationService(ref);
});

class NotesNavigationService {
  final Ref ref;

  NotesNavigationService(this.ref);

  Future<void> openNote({required String noteId}) async {
    ref
        .read(navigationServiceProvider)
        .popUntil((route) => route.settings.name != AppRoutes.notePage.name);

    ref
        .read(curSelectedNoteIdNotifierProvider.notifier)
        .setNoteId(noteId);

    ref
        .read(noteAttachmentsServiceProvider.notifier)
        .fetchNoteAttachments(noteId: noteId);

    await _navigateToNotePage(
      mode: EditablePageMode.edit,
      noteId: noteId,
    ) // invalidate the note attachments service provider to clear the attachments state
        .then((_) => ref.invalidate(noteAttachmentsServiceProvider));
  }

  Future<void> openNewNote({String? parentProjectId}) async {
    ref
        .read(navigationServiceProvider)
        .popUntil((route) => route.settings.name != AppRoutes.notePage.name);

    await ref
        .read(curSelectedNoteIdNotifierProvider.notifier)
        .createNewNote(parentProjectId: parentProjectId);

    final noteId = ref.watch(curSelectedNoteIdNotifierProvider)!;

    await _navigateToNotePage(
      mode: EditablePageMode.create,
      noteId: noteId,
    ) // invalidate the note attachments service provider to clear the attachments state
        .then((_) => ref.invalidate(noteAttachmentsServiceProvider));
  }

  Future<void> _navigateToNotePage({
    required EditablePageMode mode,
    required String noteId,
  }) async {
    final context = ref.read(navigationServiceProvider).context;

    final actions = [ShareNoteButton(noteId), DeleteNoteButton(noteId)];

    final title = mode == EditablePageMode.create
        ? AppLocalizations.of(context)!.createNote
        : AppLocalizations.of(context)!.updateNote;

    ref.read(navigationServiceProvider).navigateTo(
      AppRoutes.notePage.name,
      arguments: {
        'mode': mode,
        'actions': actions,
        'title': title,
      },
    );
  }
}
