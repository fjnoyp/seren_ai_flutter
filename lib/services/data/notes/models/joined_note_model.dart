import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_read_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

class JoinedNoteModel {
  final NoteModel note;
  final UserModel? authorUser;
  final ProjectModel? project;

  JoinedNoteModel({
    required this.note,
    required this.authorUser,
    required this.project,
  });

  static JoinedNoteModel empty() {
    return JoinedNoteModel(
      note: NoteModel.defaultNote(),
      authorUser: null,
      project: null,
    );
  }

  JoinedNoteModel copyWith({
    NoteModel? note,
    UserModel? authorUser,
    ProjectModel? project,
    String? name,
    DateTime? date,
    String? address,
    String? description,
    String? actionRequired,
    StatusEnum? status,
    bool setAsPersonal = false,
  }) {
    return JoinedNoteModel(
      note: note ??
          this.note.copyWith(
                name: name,
                authorUserId: authorUser?.id,
                date: date,
                address: address,
                description: description,
                actionRequired: actionRequired,
                status: status,
                parentProjectId: setAsPersonal ? null : project?.id,
                setAsPersonal: setAsPersonal,
              ),
      authorUser: authorUser ?? this.authorUser,
      project: setAsPersonal ? null : project ?? this.project,
    );
  }

  static Future<JoinedNoteModel> fromNoteModel(
      Ref ref, NoteModel noteModel) async {
    final authorId = noteModel.authorUserId;
    final authorUser = await ref.read(usersRepositoryProvider).getUser(userId: authorId);

    final projectId = noteModel.parentProjectId;
    final project = projectId != null
        ? await ref.read(projectsReadProvider).getItem(id: projectId)
        : null;

    return JoinedNoteModel(
        note: noteModel, authorUser: authorUser, project: project);
  }

  factory JoinedNoteModel.fromJson(Map<String, dynamic> json) {
    final noteJson = jsonDecode(json['note']);
    final authorUserJson = jsonDecode(json['author_user']);
    final projectJson = jsonDecode(json['project']);

    final note = NoteModel.fromJson(noteJson);
    final authorUser = UserModel.fromJson(authorUserJson);
    final project = ProjectModel.fromJson(projectJson);

    return JoinedNoteModel(note: note, authorUser: authorUser, project: project);
  }
}
