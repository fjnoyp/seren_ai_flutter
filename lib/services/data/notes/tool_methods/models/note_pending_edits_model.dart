import 'dart:convert';

import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/note_edit_operation.dart';

/// Model for handling pending edits to a note
/// This is stored in the description field of a note when there are pending edits
class NotePendingEditsModel {
  /// The original text of the note before edits
  final String originalText;

  /// The list of edit operations to apply
  final List<NoteEditOperation> operations;

  NotePendingEditsModel({
    required this.originalText,
    required this.operations,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'type': 'PENDING_EDITS', // Marker to identify this as pending edits
      'originalText': originalText,
      'operations': operations.map((op) => op.toJson()).toList(),
    };
  }

  /// Convert JSON to string representation for storage in the note description
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create from JSON map
  factory NotePendingEditsModel.fromJson(Map<String, dynamic> json) {
    return NotePendingEditsModel(
      originalText: json['originalText'],
      operations: (json['operations'] as List)
          .map((op) => NoteEditOperation.fromJson(op))
          .toList(),
    );
  }

  /// Check if a string contains pending edits
  static bool isPendingEdits(String? text) {
    if (text == null || text.isEmpty) return false;

    try {
      final json = jsonDecode(text);
      return json is Map<String, dynamic> &&
          json.containsKey('type') &&
          json['type'] == 'PENDING_EDITS';
    } catch (e) {
      return false;
    }
  }

  /// Parse pending edits from a string
  static NotePendingEditsModel? fromString(String? text) {
    if (!isPendingEdits(text)) return null;

    try {
      final json = jsonDecode(text!);
      return NotePendingEditsModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Apply the edit operations to get the final text
  String applyEdits() {
    // If we only have one "keep" operation with the entire content,
    // just return it directly
    if (operations.length == 1 && operations[0].type == 'keep') {
      return operations[0].text;
    }

    // Check if we have any "keep" operations
    final hasKeepOperations = operations.any((op) => op.type == 'keep');
    final hasRemoveOperations = operations.any((op) => op.type == 'remove');

    // If there are no "keep" operations but there are "add" operations,
    // and we're not removing anything, we should preserve the original text
    // and just append the additions
    if (!hasKeepOperations && !hasRemoveOperations) {
      // All the operations must be "add" operations
      final addedText = operations
          .where((op) => op.type == 'add')
          .map((op) => op.text)
          .join();

      // Return original text + additions
      return originalText + addedText;
    }

    // Normal case: Build the final text by applying operations in sequence
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
