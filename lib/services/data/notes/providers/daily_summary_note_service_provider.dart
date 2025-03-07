import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/ai/ai_context_helper/ai_context_helper_provider.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final dailySummaryNoteServiceProvider =
    Provider<DailySummaryNoteService>((ref) {
  return DailySummaryNoteService(ref);
});

class DailySummaryNoteService {
  final Ref ref;

  DailySummaryNoteService(this.ref);

  // TODO p3: improve this functions using org/project references
  Future<NoteModel> _createDailySummaryNote(
    DateTime date, {
    String? additionalInstructions,
  }) async {
    final curUser = ref.read(curUserProvider).value;
    if (curUser == null) {
      throw Exception('User not logged in');
    }

    final notesRepo = ref.read(notesRepositoryProvider);
    final aiContextHelper = ref.read(aiContextHelperProvider);

    // Get the summary content
    final summaryContent = await aiContextHelper.getDailyNotificationsSummary(
      date,
      additionalInstructions: additionalInstructions,
    );

    final context =
        ref.read(navigationServiceProvider).navigatorKey.currentContext;
    if (context == null) {
      throw Exception('Context not found');
    }

    final dateString =
        DateFormat.yMd(AppLocalizations.of(context)?.localeName).format(date);

    final newNote = NoteModel(
      name: '$_titlePrefix: $dateString',
      authorUserId: curUser.id,
      date: date,
      description: summaryContent,
    );

    await notesRepo.insertItem(newNote);
    return newNote;
  }

  Future<NoteModel> _updateDailySummaryNote(
    NoteModel existingNote, {
    String? additionalInstructions,
  }) async {
    final aiContextHelper = ref.read(aiContextHelperProvider);
    final notesRepo = ref.read(notesRepositoryProvider);

    // Get the summary content
    final summaryContent = await aiContextHelper.getDailyNotificationsSummary(
      existingNote.date ?? DateTime.now(),
      additionalInstructions: additionalInstructions,
    );

    final updatedNote = existingNote.copyWith(description: summaryContent);
    await notesRepo.updateItem(updatedNote);
    return updatedNote;
  }

  Future<NoteModel> createOrUpdateDailySummaryNote(DateTime date,
      {String? additionalInstructions}) async {
    final curUser = ref.read(curUserProvider).value;
    if (curUser == null) {
      throw Exception('User not logged in');
    }

    final existingNote = await _getDailySummaryNote(date);

    if (existingNote == null) {
      // Create new note
      return await _createDailySummaryNote(
        date,
        additionalInstructions: additionalInstructions,
      );
    } else {
      // Update existing note
      return await _updateDailySummaryNote(
        existingNote,
        additionalInstructions: additionalInstructions,
      );
    }
  }

  Future<NoteModel> getOrCreateDailySummaryNote(
    DateTime date, {
    String? additionalInstructions,
  }) async {
    final curUser = ref.read(curUserProvider).value;
    if (curUser == null) {
      throw Exception('User not logged in');
    }

    final existingNote = await _getDailySummaryNote(date);

    if (existingNote != null) {
      return existingNote;
    } else {
      // If note doesn't exist, create it
      return await _createDailySummaryNote(
        date,
        additionalInstructions: additionalInstructions,
      );
    }
  }

  Future<void> deleteDailySummaryNote(DateTime date) async {
    final notesRepo = ref.read(notesRepositoryProvider);
    final curUser = ref.read(curUserProvider).value;
    if (curUser == null) {
      throw Exception('User not logged in');
    }
    final noteAsync = await _getDailySummaryNote(date);

    if (noteAsync != null) {
      await notesRepo.deleteItem(noteAsync.id);
    }
  }

  Future<NoteModel?> _getDailySummaryNote(DateTime date) async {
    final curUser = ref.read(curUserProvider).value;
    if (curUser == null) {
      throw Exception('User not logged in');
    }
    final notesRepo = ref.read(notesRepositoryProvider);

    return await notesRepo.getDailySummaryNote(
      date: date,
      userId: curUser.id,
      titlePrefix: _titlePrefix,
    );
  }

  String get _titlePrefix {
    final context =
        ref.read(navigationServiceProvider).navigatorKey.currentContext;
    if (context == null) {
      throw Exception('Context not found');
    }

    return AppLocalizations.of(context)?.dailySummary ?? 'Daily Summary';
  }
}
