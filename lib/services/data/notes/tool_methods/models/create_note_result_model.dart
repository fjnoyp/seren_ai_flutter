import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/note_request_models.dart';

class CreateNoteResultModel extends AiRequestResultModel {
  final NoteModel note;

  CreateNoteResultModel({
    required this.note,
    required String resultForAi,
  }) : super(
          resultForAi: resultForAi,
          resultType: AiRequestResultType.createNote,
        );

  factory CreateNoteResultModel.fromNoteAndRequest({
    required NoteModel note,
    required CreateNoteRequestModel request,
    required String resultForAi,
    required bool showOnly,
  }) {
    return CreateNoteResultModel(
      note: note,
      resultForAi: resultForAi,
    );
  }

  factory CreateNoteResultModel.fromJson(Map<String, dynamic> json) {
    final noteData = json['note'] as Map<String, dynamic>;
    return CreateNoteResultModel(
      note: NoteModel(
        id: noteData['id'],
        name: noteData['name'],
        description: noteData['description'],
        authorUserId: noteData['author_user_id'] ?? '',
        createdAt: noteData['created_at'] != null
            ? DateTime.parse(noteData['created_at'])
            : null,
        updatedAt: noteData['updated_at'] != null
            ? DateTime.parse(noteData['updated_at'])
            : null,
      ),
      resultForAi: json['result_for_ai'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'note': {
        'id': note.id,
        'name': note.name,
        'description': note.description,
        'created_at': note.createdAt?.toIso8601String(),
        'updated_at': note.updatedAt?.toIso8601String(),
      },
      'result_for_ai': resultForAi,
    };
  }
}
