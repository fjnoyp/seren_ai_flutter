import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/base_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_selected_note_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_attachments_service_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/delete_note_button.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/pdf/share_note_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';

final notesNavigationServiceProvider = Provider<NotesNavigationService>((ref) {
  return NotesNavigationService(ref);
});

class NotesNavigationService extends BaseNavigationService {
  NotesNavigationService(super.ref);

  @override
  NotifierProvider get idNotifierProvider => curSelectedNoteIdNotifierProvider;

  @override
  Future<void> setIdFunction(String id) async {
    await _ensureNoteOrgIsSelected(id);
    ref.read(curSelectedNoteIdNotifierProvider.notifier).setNoteId(id);
  }

  Future<void> openNote({required String noteId}) async {
    ref.read(curSelectedNoteIdNotifierProvider.notifier).setNoteId(noteId);

    ref
        .read(noteAttachmentsServiceProvider.notifier)
        .fetchNoteAttachments(noteId: noteId);

    await _ensureNoteOrgIsSelected(noteId);

    await _navigateToNotePage(
      mode: EditablePageMode.edit,
      noteId: noteId,
    ) // invalidate the note attachments service provider to clear the attachments state
        .then((_) => ref.invalidate(noteAttachmentsServiceProvider));
  }

  Future<void> openNewNote({String? parentProjectId}) async {
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

  Future<void> _ensureNoteOrgIsSelected(String noteId) async {
    final note = await ref.read(noteByIdStreamProvider(noteId).future);
    if (note == null) {
      throw Exception('Note not found');
    }

    final curSelectedOrgId = ref.read(curSelectedOrgIdNotifierProvider);

    // Get the note's parent org ID from the repository
    final noteParentOrgId =
        await ref.read(notesRepositoryProvider).getNoteParentOrgId(noteId);

    if (noteParentOrgId != null && noteParentOrgId != curSelectedOrgId) {
      await ref
          .read(curSelectedOrgIdNotifierProvider.notifier)
          .setDesiredOrgId(noteParentOrgId);
    }
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
          '${AppRoutes.notePage.name}/$noteId',
          arguments: {'mode': mode, 'actions': actions, 'title': title},
          withReplacement: ref
              .read(currentRouteProvider)
              .startsWith(AppRoutes.notePage.name),
        );
  }
}
