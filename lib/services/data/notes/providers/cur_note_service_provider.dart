import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_db_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_note_state_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';

final curNoteServiceProvider = Provider<CurNoteService>((ref) {
  return CurNoteService(ref);
});

class CurNoteService {
  final Ref ref;
  final AsyncValue<JoinedNoteModel?> _state;
  final CurNoteStateNotifier _notifier;

  CurNoteService(this.ref)
      : _state = ref.watch(curNoteStateProvider),
        _notifier = ref.watch(curNoteStateProvider.notifier);

  void createNote({String? parentProjectId}) {
    _notifier.setToNewNote(parentProjectId: parentProjectId);
  }

  void loadNote(JoinedNoteModel joinedNote) {
    _notifier.setNewNote(joinedNote);
  }

  String get curNoteId => _state.value?.note.id ?? '';

  bool isValidNote() {
    return _state.value != null && _state.value!.note.name.isNotEmpty;
  }

  Future<void> updateNote(NoteModel note) async {
    if (_state.value != null) {
      _notifier.setNewNote(await JoinedNoteModel.fromNoteModel(ref, note));
    }
  }

  void updateNoteName(String name) {
    if (_state.value != null) {
      _notifier.setNewNote(_state.value!.copyWith(name: name));
    }
  }

  void updateDate(DateTime date) {
    if (_state.value != null) {
      _notifier.setNewNote(_state.value!.copyWith(date: date));
    }
  }

  void updateAddress(String? address) {
    if (_state.value != null) {
      _notifier.setNewNote(_state.value!.copyWith(address: address));
    }
  }

  void updateDescription(String? description) {
    if (_state.value != null) {
      _notifier.setNewNote(_state.value!.copyWith(description: description));
    }
  }

  void updateActionRequired(String? actionRequired) {
    if (_state.value != null) {
      _notifier
          .setNewNote(_state.value!.copyWith(actionRequired: actionRequired));
    }
  }

  void updateStatus(StatusEnum? status) {
    if (_state.value != null) {
      _notifier.setNewNote(_state.value!.copyWith(status: status));
    }
  }

  void updateParentProject(ProjectModel? project) {
    if (_state.value != null) {
      _notifier.setNewNote(_state.value!
          .copyWith(project: project, setAsPersonal: project == null));
    }
  }

  Future<void> saveNote() async {
    if (_state.value != null) {
      if (isValidNote()) {
        await ref.read(notesDbProvider).upsertItem(_state.value!.note);
      }
    }
  }

  Future<void> deleteNote() async {
    if (_state.value != null) {
      await ref.read(notesDbProvider).deleteItem(_state.value!.note.id);
    }
  }
}
