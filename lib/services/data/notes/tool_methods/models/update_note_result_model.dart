import 'dart:convert';

import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/note_edit_operation.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/note_request_models.dart';

/// Result model returned when a note is updated
class UpdateNoteResultModel extends AiRequestResultModel {
  /// The note that was updated
  final NoteModel note;

  /// The original request model
  final UpdateNoteRequestModel request;

  /// The list of edit operations applied to the note
  final List<NoteEditOperation> editOperations;

  UpdateNoteResultModel({
    required this.note,
    required this.request,
    required this.editOperations,
    required String resultForAi,
    String? resultForUser,
  }) : super(
          resultForAi: resultForAi,
          resultType: AiRequestResultType.updateNote,
        );

  /// Create an UpdateNoteResultModel from a note, request, and result message
  factory UpdateNoteResultModel.fromNoteAndRequest({
    required NoteModel note,
    required UpdateNoteRequestModel request,
    required String resultForAi,
    String? resultForUser,
  }) {
    // Parse the edit operations from the request
    final List<NoteEditOperation> editOperations =
        request.parseEditOperations();

    return UpdateNoteResultModel(
      note: note,
      request: request,
      editOperations: editOperations,
      resultForAi: resultForAi,
      resultForUser: resultForUser,
    );
  }

  factory UpdateNoteResultModel.fromJson(Map<String, dynamic> json) {
    // Parse the note JSON
    final NoteModel note = NoteModel.fromJson(json['note']);

    // Parse the request JSON
    final UpdateNoteRequestModel request = UpdateNoteRequestModel(
      noteName: json['request']['note_name'],
      updatedNoteDescription: json['request']['updated_note_description'],
      showToUser: json['request']['show_to_user'] ?? true,
    );

    // Parse edit operations
    final List<NoteEditOperation> editOperations =
        (json['edit_operations'] as List)
            .map((op) => NoteEditOperation.fromJson(op))
            .toList();

    return UpdateNoteResultModel(
      note: note,
      request: request,
      editOperations: editOperations,
      resultForAi: json['result_for_ai'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'result_type': resultType.value,
      'result_for_ai': resultForAi,
      'note': note.toJson(),
      'request': {
        'note_name': request.noteName,
        'updated_note_description': request.updatedNoteDescription,
        'show_to_user': request.showToUser,
      },
      'edit_operations': editOperations.map((op) => op.toJson()).toList(),
    };
  }
}
