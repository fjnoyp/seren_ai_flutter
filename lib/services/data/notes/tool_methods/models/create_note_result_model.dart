import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/note_request_models.dart';

class CreateNoteResultModel extends AiRequestResultModel {
  final NoteModel note;
  final Map<String, dynamic> createdFields;

  CreateNoteResultModel({
    required this.note,
    required String resultForAi,
    this.createdFields = const {},
  }) : super(
          resultForAi: resultForAi,
          resultType: AiRequestResultType.createNote,
        );

  /// Factory constructor that processes the fields from the request
  factory CreateNoteResultModel.fromNoteAndRequest({
    required NoteModel note,
    required CreateNoteRequestModel request,
    required String resultForAi,
  }) {
    final createdFields = _processCreatedFields(request);

    return CreateNoteResultModel(
      note: note,
      resultForAi: resultForAi,
      createdFields: createdFields,
    );
  }

  /// Process fields that were set during creation
  static Map<String, dynamic> _processCreatedFields(
      CreateNoteRequestModel request) {
    final Map<String, dynamic> createdFields = {
      'name': request.noteName,
    };

    if (request.noteDescription != null) {
      createdFields['description'] = request.noteDescription;
    }

    return createdFields;
  }

  factory CreateNoteResultModel.fromJson(Map<String, dynamic> json) {
    return CreateNoteResultModel(
      note: NoteModel.fromJson(json['note']),
      resultForAi: json['result_for_ai'],
      createdFields: json['created_fields'] ?? {},
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        'note': note.toJson(),
        'created_fields': createdFields,
      });
  }
}
