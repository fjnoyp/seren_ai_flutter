import 'package:seren_ai_flutter/services/data/notes/models/joined_note_folder_model.dart';

abstract class CurNoteFolderState {}

class InitialCurNoteFolderState extends CurNoteFolderState {}

class LoadingCurNoteFolderState extends CurNoteFolderState {}

class LoadedCurNoteFolderState extends CurNoteFolderState {
  final JoinedNoteFolderModel noteFolder;

  LoadedCurNoteFolderState(this.noteFolder);
}

class ErrorCurNoteFolderState extends CurNoteFolderState {
  final String error;

  ErrorCurNoteFolderState({required this.error});
}
