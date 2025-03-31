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
      // TODO: Implement navigation to note detail page
      log('would open note page, but not implemented yet');

      // Example navigation pattern following task implementation:
      // ref.read(curSelectedNoteIdNotifierProvider.notifier).setNoteId(newNote.id);
      // ref.read(navigationServiceProvider).navigateTo(AppRoutes.notePage.name, arguments: {
      //   'mode': EditablePageMode.readOnly,
      //   'title': newNote.name,
      // });
    } else {
      log('did not open note page, UI actions are not allowed');
    }

    // Return result model
    return CreateNoteResultModel(
      note: newNote,
      resultForAi: 'Created new note "${newNote.name}"',
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
