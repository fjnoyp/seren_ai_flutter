import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

final curEditingNoteStateProvider =
    NotifierProvider<EditingNoteNotifier, AsyncValue<EditingNoteState>>(() {
  return EditingNoteNotifier();
});

class EditingNoteState {
  NoteModel noteModel;
  UserModel? authorUser;
  ProjectModel? project;

  EditingNoteState({
    required this.noteModel,
    this.authorUser,
    this.project,
  });

  EditingNoteState copyWith({
    NoteModel? noteModel,
    UserModel? authorUser,
    ProjectModel? project,
  }) {
    return EditingNoteState(
      noteModel: noteModel ?? this.noteModel,
      authorUser: authorUser ?? this.authorUser,
      project: project ?? this.project,
    );
  }
}

class EditingNoteNotifier extends Notifier<AsyncValue<EditingNoteState>> {
  @override
  AsyncValue<EditingNoteState> build() {
    return AsyncValue.data(EditingNoteState(
      noteModel: NoteModel.defaultNote(),
    ));
  }

  Future<void> createNewNote({String? parentProjectId}) async {
    state = const AsyncValue.loading();
    try {
      final curUser = ref.read(curUserProvider).value;
      if (curUser == null) throw Exception('No current user');

      final newNote = NoteModel.defaultNote().copyWith(
        authorUserId: curUser.id,
        parentProjectId: parentProjectId,
        setAsPersonal: parentProjectId == null,
      );

      state = AsyncValue.data(EditingNoteState(
        noteModel: newNote,
        authorUser: curUser,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadNote(NoteModel note) async {
    state = const AsyncValue.loading();
    try {
      final authorUser =
          await ref.read(usersRepositoryProvider).getById(note.authorUserId);

      ProjectModel? project;
      if (note.parentProjectId != null) {
        project = await ref
            .read(projectsRepositoryProvider)
            .getById(note.parentProjectId!);
      }

      state = AsyncValue.data(EditingNoteState(
        noteModel: note,
        authorUser: authorUser,
        project: project,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateFields({
    String? name,
    DateTime? date,
    String? address,
    String? description,
    String? actionRequired,
    StatusEnum? status,
    ProjectModel? project,
    bool setAsPersonal = false,
  }) {
    state.whenData((currentState) {
      final currentNote = currentState.noteModel;
      final updatedNote = currentNote.copyWith(
        name: name ?? currentNote.name,
        date: date ?? currentNote.date,
        address: address ?? currentNote.address,
        description: description ?? currentNote.description,
        actionRequired: actionRequired ?? currentNote.actionRequired,
        status: status ?? currentNote.status,
        parentProjectId:
            setAsPersonal ? null : project?.id ?? currentNote.parentProjectId,
      );
      state = AsyncValue.data(currentState.copyWith(
        noteModel: updatedNote,
        project: setAsPersonal ? null : project ?? currentState.project,
      ));
    });
  }

  Future<void> saveChanges() async {
    state.whenData((currentState) async {
      if (currentState.noteModel.name.isNotEmpty) {
        await ref
            .read(notesRepositoryProvider)
            .upsertItem(currentState.noteModel);
      }
    });
  }

  Future<void> deleteNote() async {
    state.whenData((currentState) async {
      await ref
          .read(notesRepositoryProvider)
          .deleteItem(currentState.noteModel.id);
    });
  }

  Future<Map<String, dynamic>> toReadableMap() async {
    final value = state
        .whenData((currentState) => {
              'note': {
                'name': currentState.noteModel.name,
                'description': currentState.noteModel.description,
                'status': currentState.noteModel.status,
                'date': currentState.noteModel.date?.toIso8601String(),
                'address': currentState.noteModel.address,
                'action_required': currentState.noteModel.actionRequired,
              },
              'author': currentState.authorUser?.email ?? 'Unknown',
              'project': currentState.project?.name ?? 'No Project',
            })
        .value;

    return value ?? {};
  }

  String get curNoteId => state.valueOrNull?.noteModel.id ?? '';

  bool get isValid => state.valueOrNull?.noteModel.name.isNotEmpty ?? false;
}
