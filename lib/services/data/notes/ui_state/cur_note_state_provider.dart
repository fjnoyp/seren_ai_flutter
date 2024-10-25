import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_read_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_states.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final curNoteStateProvider =
    NotifierProvider<CurNoteNotifier, CurNoteState>(CurNoteNotifier.new);

class CurNoteNotifier extends Notifier<CurNoteState> {
  @override
  CurNoteState build() {
    return InitialCurNoteState();
  }

  // Needed in case of reset
  List<String> _initialNoteAttachmentUrls = [];
  final supabaseStorage = Supabase.instance.client.storage;
  String get curNoteId => (state as LoadedCurNoteState).joinedNote.note.id;

  String _fileName(String filePath) => Uri.decodeFull(filePath).split('/').last;

  Future<void> setNewNote(NoteModel note) async {
    state = LoadedCurNoteState(await JoinedNoteModel.fromNoteModel(ref, note));
    _fetchNoteAttachments(firstLoad: true);
  }

  Future<void> setToNewNote() async {
    state = LoadingCurNoteState();
    try {
      final curUser =
          (ref.read(curAuthStateProvider) as LoggedInAuthState).user;

      final newNote = NoteModel.defaultNote().copyWith(
        authorUserId: curUser.id,
        parentProjectId: curUser.defaultProjectId,
      );

      state =
          LoadedCurNoteState(await JoinedNoteModel.fromNoteModel(ref, newNote));
    } catch (error) {
      state = ErrorCurNoteState(error: error.toString());
    }
  }

  bool isValidNote() {
    return state is LoadedCurNoteState &&
        (state as LoadedCurNoteState).joinedNote.note.name.isNotEmpty;
  }

  Future<void> updateNote(NoteModel note) async {
    if (state is LoadedCurNoteState) {
      state =
          LoadedCurNoteState(await JoinedNoteModel.fromNoteModel(ref, note));
    }
  }

  void updateNoteName(String name) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(loadedState.joinedNote.copyWith(name: name));
    }
  }

  // TODO: we shouldn't be able to freely update date
  // refactor to set date only when creating new note
  void updateDate(DateTime date) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(loadedState.joinedNote.copyWith(date: date));
    }
  }

  void updateAddress(String? address) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state =
          LoadedCurNoteState(loadedState.joinedNote.copyWith(address: address));
    }
  }

  void updateDescription(String? description) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(
          loadedState.joinedNote.copyWith(description: description));
    }
  }

  void updateActionRequired(String? actionRequired) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(
          loadedState.joinedNote.copyWith(actionRequired: actionRequired));
    }
  }

  void updateStatus(StatusEnum? status) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state =
          LoadedCurNoteState(loadedState.joinedNote.copyWith(status: status));
    }
  }

  void updateParentProject(ProjectModel? project) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(loadedState.joinedNote
          .copyWith(project: project, setAsPersonal: project == null));
    }
  }

  Future<void> saveNote() async {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      await ref.read(notesReadProvider).upsertItem(loadedState.joinedNote.note);
    }
  }

  Future<void> _fetchNoteAttachments({bool firstLoad = false}) async {
    if (state is LoadedCurNoteState) {
      final curNote = (state as LoadedCurNoteState).joinedNote;
      final attachments = await supabaseStorage
          .from('note_attachments')
          .list(path: curNote.note.id);
      attachments.removeWhere((e) => e.name.startsWith('.'));

      final noteAttachmentUrls = attachments
          .map((e) => supabaseStorage
              .from('note_attachments')
              .getPublicUrl('${curNote.note.id}/${e.name}'))
          .toList();

      if (firstLoad) {
        _initialNoteAttachmentUrls = noteAttachmentUrls;
      }

      state = LoadedCurNoteState(
          curNote.copyWith(attachmentUrls: noteAttachmentUrls));
    }
  }

  Future<void> uploadAttachments(List<File> files) async {
    for (var file in files) {
      await supabaseStorage.from('note_attachments').upload(
            '$curNoteId/${_fileName(file.path)}',
            file,
            fileOptions: const FileOptions(upsert: true),
          );
    }
    _fetchNoteAttachments();
  }

  Future<void> resetAttachments() async {
    final attachmentsToRemove =
        await supabaseStorage.from('note_attachments').list(path: curNoteId);
    attachmentsToRemove.removeWhere((e) =>
        _initialNoteAttachmentUrls.any((url) => e.name == _fileName(url)));

    await supabaseStorage.from('note_attachments').remove(
        attachmentsToRemove.map((e) => '$curNoteId/${e.name}').toList());
  }

  Future<bool> openAttachmentLocally(String fileUrl) async {
    final fileBytes = await supabaseStorage
        .from('note_attachments')
        .download('$curNoteId/${_fileName(fileUrl)}');
    final path = await getDownloadsDirectory();
    final file = File('${path?.path}/${_fileName(fileUrl)}');
    await file.writeAsBytes(fileBytes);
    await OpenFile.open(file.path);
    return true;
  }

  Future<void> deleteAttachment(String fileUrl) async {
    await supabaseStorage
        .from('note_attachments')
        .remove(['$curNoteId/${_fileName(fileUrl)}']);
    _fetchNoteAttachments();
  }
}

// Providers for individual fields

final curNoteAuthorProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.joinedNote.note.authorUserId,
    _ => null,
  };
});

final curNoteDateProvider = Provider<DateTime?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.joinedNote.note.date,
    _ => null,
  };
});

final curNoteAddressProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.joinedNote.note.address,
    _ => null,
  };
});

final curNoteDescriptionProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.joinedNote.note.description,
    _ => null,
  };
});

final curNoteActionRequiredProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.joinedNote.note.actionRequired,
    _ => null,
  };
});

final curNoteStatusProvider = Provider<StatusEnum?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.joinedNote.note.status,
    _ => null,
  };
});

final curNoteProjectProvider = Provider<ProjectModel?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.joinedNote.project,
    _ => null,
  };
});
