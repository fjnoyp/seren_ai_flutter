import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_folder_model.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

class JoinedNoteFolderModel {
  final NoteFolderModel noteFolder; 
  final ProjectModel? project; 
  final TeamModel? team; 

  JoinedNoteFolderModel({
    required this.noteFolder,
    this.project,
    this.team,
  });

  static JoinedNoteFolderModel empty() {
    return JoinedNoteFolderModel(
      noteFolder: NoteFolderModel.defaultNoteFolder(),
      project: null,
      team: null
    );
  }

  JoinedNoteFolderModel copyWith({
    NoteFolderModel? noteFolder,
    ProjectModel? project,
    TeamModel? team,    
  }) {
    return JoinedNoteFolderModel(
      noteFolder: noteFolder ?? this.noteFolder,
      project: project ?? this.project,
      team: team ?? this.team,      
    );
  }
}
