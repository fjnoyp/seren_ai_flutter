import 'dart:convert';

import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_info_request_model.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/note_edit_operation.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/note_pending_edits_model.dart';

class CreateNoteRequestModel extends AiActionRequestModel {
  final String noteName;
  final String noteDescription;
  final bool showToUser;

  CreateNoteRequestModel({
    required this.noteName,
    required this.noteDescription,
    this.showToUser = true,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.createNote);

  static CreateNoteRequestModel fromJson(Map<String, dynamic> json) {
    return CreateNoteRequestModel(
      args: json['args'],
      noteName: json['args']['note_name'],
      noteDescription: json['args']['note_description'],
      showToUser: json['args']['show_to_user'] ?? true,
    );
  }
}

class UpdateNoteRequestModel extends AiActionRequestModel {
  final String noteName;
  final String updatedNoteDescription;
  final bool showToUser;

  UpdateNoteRequestModel({
    required this.noteName,
    required this.updatedNoteDescription,
    this.showToUser = true,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.updateNote);

  static UpdateNoteRequestModel fromJson(Map<String, dynamic> json) {
    return UpdateNoteRequestModel(
      args: json['args'],
      noteName: json['args']['note_name'],
      updatedNoteDescription: json['args']['updated_note_description'],
      showToUser: json['args']['show_to_user'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'args': {
        'note_name': noteName,
        'updated_note_description': updatedNoteDescription,
        'show_to_user': showToUser,
      },
    };
  }

  /// Parse the updatedNoteDescription as a JSON array of edit operations
  /// Returns a list of NoteEditOperation objects
  List<NoteEditOperation> parseEditOperations() {
    // If the description is empty, return an empty list
    if (updatedNoteDescription.trim().isEmpty) {
      return [];
    }

    try {
      // Check if the description is already a valid JSON array
      final dynamic decoded = jsonDecode(updatedNoteDescription);

      // Handle case where it's a simple string - treat as a single "keep" operation
      if (decoded is String) {
        return [NoteEditOperation(type: 'keep', text: decoded)];
      }

      // Handle case where it's not an array - treat the entire content as a single "keep" operation
      if (decoded is! List) {
        return [NoteEditOperation(type: 'keep', text: updatedNoteDescription)];
      }

      final List<dynamic> operationsJson = decoded;
      final operations =
          operationsJson.map((op) => NoteEditOperation.fromJson(op)).toList();

      // Validate operations - ensure we have at least one operation
      if (operations.isEmpty) {
        return [NoteEditOperation(type: 'keep', text: updatedNoteDescription)];
      }

      // Ensure we have the required types
      bool hasValidTypes = true;
      for (final op in operations) {
        if (op.type != 'keep' && op.type != 'add' && op.type != 'remove') {
          hasValidTypes = false;
          break;
        }
      }

      if (!hasValidTypes) {
        return [NoteEditOperation(type: 'keep', text: updatedNoteDescription)];
      }

      return operations;
    } catch (e) {
      // If parsing fails, treat the entire content as a single "keep" operation
      // This ensures backward compatibility if we receive a plain string
      return [NoteEditOperation(type: 'keep', text: updatedNoteDescription)];
    }
  }

  /// Create a pending edits model for the original text
  /// This stores both the original text and the proposed changes
  NotePendingEditsModel createPendingEdits(String originalText) {
    return NotePendingEditsModel(
      originalText: originalText,
      operations: parseEditOperations(),
    );
  }

  /// Format the edit operations as a pending edits JSON string
  /// This can be stored in the note description field
  String formatAsPendingEdits(String originalText) {
    final pendingEdits = createPendingEdits(originalText);
    return pendingEdits.toJsonString();
  }

  /// Apply edit operations to transform the original text
  /// Returns the resulting text after applying all operations
  /// Note: This is deprecated, use formatAsPendingEdits instead
  /// to allow user confirmation before applying changes
  @deprecated
  String applyEditOperations(String originalText) {
    final operations = parseEditOperations();

    // If we only have one "keep" operation with the entire content,
    // just return the updated description directly
    if (operations.length == 1 && operations[0].type == 'keep') {
      return operations[0].text;
    }

    // Handle empty operations list
    if (operations.isEmpty) {
      return '';
    }

    // Build the final text by applying operations in sequence
    final buffer = StringBuffer();
    for (final op in operations) {
      if (op.type == 'keep' || op.type == 'add') {
        buffer.write(op.text);
      }
      // 'remove' operations are skipped
    }

    return buffer.toString();
  }
}

class ShareNoteRequestModel extends AiActionRequestModel {
  final String noteName;
  final bool showToUser;

  ShareNoteRequestModel({
    required this.noteName,
    this.showToUser = true,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.shareNote);

  static ShareNoteRequestModel fromJson(Map<String, dynamic> json) {
    return ShareNoteRequestModel(
      args: json['args'],
      noteName: json['args']['note_name'],
      showToUser: json['args']['show_to_user'] ?? true,
    );
  }
}

class DeleteNoteRequestModel extends AiActionRequestModel {
  final String noteName;
  final bool showToUser;

  DeleteNoteRequestModel({
    required this.noteName,
    this.showToUser = true,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.deleteNote);

  static DeleteNoteRequestModel fromJson(Map<String, dynamic> json) {
    return DeleteNoteRequestModel(
      args: json['args'],
      noteName: json['args']['note_name'],
      showToUser: json['args']['show_to_user'] ?? true,
    );
  }
}

class ShowNotesRequestModel extends AiActionRequestModel {
  final String? noteName;
  final bool showToUser;

  ShowNotesRequestModel({
    this.noteName,
    this.showToUser = true,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.showNotes);

  static ShowNotesRequestModel fromJson(Map<String, dynamic> json) {
    return ShowNotesRequestModel(
      args: json['args'],
      noteName: json['args']['note_name'],
      showToUser: json['args']['show_to_user'] ?? true,
    );
  }
}

class FindNotesRequestModel extends AiInfoRequestModel {
  final String? noteName;
  final String? noteCreatedDateStart;
  final String? noteCreatedDateEnd;
  final String? noteUpdatedDateStart;
  final String? noteUpdatedDateEnd;
  final bool showToUser;

  FindNotesRequestModel({
    this.noteName,
    this.noteCreatedDateStart,
    this.noteCreatedDateEnd,
    this.noteUpdatedDateStart,
    this.noteUpdatedDateEnd,
    this.showToUser = true,
    super.args,
  }) : super(infoRequestType: AiInfoRequestType.findNotes);

  static FindNotesRequestModel fromJson(Map<String, dynamic> json) {
    return FindNotesRequestModel(
      args: json['args'],
      noteName: json['args']['note_name'],
      noteCreatedDateStart: json['args']['note_created_date_start'],
      noteCreatedDateEnd: json['args']['note_created_date_end'],
      noteUpdatedDateStart: json['args']['note_updated_date_start'],
      noteUpdatedDateEnd: json['args']['note_updated_date_end'],
      showToUser: json['args']['show_to_user'] ?? true,
    );
  }
}
