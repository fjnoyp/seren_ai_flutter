import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';

sealed class CurNoteState {}

class InitialCurNoteState extends CurNoteState {}

class LoadingCurNoteState extends CurNoteState {}

class LoadedCurNoteState extends CurNoteState {
  final NoteModel note;

  LoadedCurNoteState(this.note);
}

class ErrorCurNoteState extends CurNoteState {
  final String error;

  ErrorCurNoteState({required this.error});
}
