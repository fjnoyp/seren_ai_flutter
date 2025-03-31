import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/results/error_request_result_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/create_note_result_model.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/note_request_models.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/delete_note_button.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/pdf/share_note_button.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_selected_note_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';

class NoteToolMethods {
  // Threshold for string similarity (0.0 to 1.0)
  static const double _similarityThreshold = 0.6;

  Future<AiRequestResultModel> createNote({
    required Ref ref,
    required CreateNoteRequestModel actionRequest,
    required bool allowToolUiActions,
  }) async {
    // === Validate Auth ===
    final curUser = ref.read(curUserProvider).valueOrNull;
    if (curUser == null) return _handleNoAuth();

    final selectedOrgId = ref.read(curSelectedOrgIdNotifierProvider);
    if (selectedOrgId == null) {
      return ErrorRequestResultModel(resultForAi: 'No org selected');
    }

    // Create a new note with fields from the request
    final newNote = NoteModel(
      name: actionRequest.noteName,
      description: actionRequest.noteDescription,
      authorUserId: curUser.id,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    // Save the note to the repository
    await ref.read(notesRepositoryProvider).upsertItem(newNote);

    // Navigate to note page if allowed
    if (allowToolUiActions) {
      // Set the selected note ID and navigate using the notes navigation service
      ref
          .read(curSelectedNoteIdNotifierProvider.notifier)
          .setNoteId(newNote.id);

      // Use the notes navigation service to open the note
      ref.read(notesNavigationServiceProvider).openNote(noteId: newNote.id);

      log('opened note page for "${newNote.name}"');
    } else {
      log('did not open note page, UI actions are not allowed');
    }

    // Return result model using the factory constructor
    final resultMessage = allowToolUiActions
        ? 'Created new note "${newNote.name}" and opened note page'
        : 'Created new note "${newNote.name}"';

    return CreateNoteResultModel.fromNoteAndRequest(
      note: newNote,
      request: actionRequest,
      resultForAi: resultMessage,
    );
  }

  String? _getUserId(Ref ref) {
    final curAuthState = ref.read(curUserProvider);
    return curAuthState.value?.id;
  }

  AiRequestResultModel _handleNoAuth() {
    return ErrorRequestResultModel(resultForAi: 'No auth');
  }
}

final noteToolMethodsProvider = Provider<NoteToolMethods>((ref) {
  return NoteToolMethods();
});
