import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/ai_context_helper/ai_context_helper_provider.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';

final dailySummaryNoteServiceProvider =
    Provider<DailySummaryNoteService>((ref) {
  return DailySummaryNoteService(ref);
});

class DailySummaryNoteService {
  final Ref ref;

  DailySummaryNoteService(this.ref);

  // TODO: improve this function using org/project references
  Future<NoteModel> createOrUpdateDailySummaryNote(DateTime date,
      {String? additionalInstructions}) async {
    final curUser = ref.read(curUserProvider).value;
    if (curUser == null) {
      throw Exception('User not logged in');
    }

    final notesRepo = ref.read(notesRepositoryProvider);
    final aiContextHelper = ref.read(aiContextHelperProvider);

    // Check if a note already exists for this day
    final existingNote = await notesRepo.getDailySummaryNote(date);

    // Get the summary content
    final summaryContent = await aiContextHelper.getDailyNotificationsSummary(
      date,
      additionalInstructions: additionalInstructions,
    );

    final dateString = '${date.year}-${date.month}-${date.day}';

    if (existingNote != null) {
      // Update existing note
      final updatedNote = existingNote.copyWith(description: summaryContent);

      await notesRepo.updateItem(updatedNote);
      return updatedNote;
    } else {
      // Create new note
      final newNote = NoteModel(
        name: 'Daily Summary: $dateString',
        authorUserId: curUser.id,
        date: date,
        description: summaryContent,
      );

      await notesRepo.insertItem(newNote);
      return newNote;
    }
  }

  Future<NoteModel> getOrCreateDailySummaryNote(DateTime date,
      {String? additionalInstructions}) async {
    final notesRepo = ref.read(notesRepositoryProvider);
    final existingNote = await notesRepo.getDailySummaryNote(date);

    if (existingNote != null) {
      return existingNote;
    } else {
      // If note doesn't exist, create it
      return await createOrUpdateDailySummaryNote(
        date,
        additionalInstructions: additionalInstructions,
      );
    }
  }

  Future<void> deleteDailySummaryNote(DateTime date) async {
    final notesRepo = ref.read(notesRepositoryProvider);
    final existingNote = await notesRepo.getDailySummaryNote(date);

    if (existingNote != null) {
      await notesRepo.deleteItem(existingNote.id);
    }
  }
}
