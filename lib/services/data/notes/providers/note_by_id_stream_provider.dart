import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';

final noteByIdStreamProvider =
    StreamProvider.family<NoteModel?, String>((ref, noteId) {
  final notesRepo = ref.read(notesRepositoryProvider);
  notesRepo.getById(noteId).then((value) => log(value.toString()));
  return notesRepo.watchById(noteId);
});
