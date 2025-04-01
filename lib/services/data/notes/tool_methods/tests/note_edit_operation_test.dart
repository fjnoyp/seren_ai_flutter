import 'package:flutter_test/flutter_test.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/note_edit_operation.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/note_request_models.dart';

void main() {
  group('NoteEditOperation', () {
    test('fromJson creates correct operation', () {
      final json = {
        'type': 'add',
        'text': 'New text',
      };
      final operation = NoteEditOperation.fromJson(json);
      expect(operation.type, 'add');
      expect(operation.text, 'New text');
    });

    test('toJson creates correct JSON', () {
      final operation =
          NoteEditOperation(type: 'remove', text: 'Text to remove');
      final json = operation.toJson();
      expect(json['type'], 'remove');
      expect(json['text'], 'Text to remove');
    });
  });

  group('UpdateNoteRequestModel', () {
    test('parseEditOperations handles valid JSON array', () {
      final model = UpdateNoteRequestModel(
        noteName: 'Test Note',
        updatedNoteDescription: '''[
          {"type": "keep", "text": "Original text"},
          {"type": "add", "text": "New text"},
          {"type": "remove", "text": "Text to remove"}
        ]''',
      );
      final operations = model.parseEditOperations();
      expect(operations.length, 3);
      expect(operations[0].type, 'keep');
      expect(operations[1].type, 'add');
      expect(operations[2].type, 'remove');
    });

    test('parseEditOperations handles plain text as keep operation', () {
      final model = UpdateNoteRequestModel(
        noteName: 'Test Note',
        updatedNoteDescription: 'Plain text content',
      );
      final operations = model.parseEditOperations();
      expect(operations.length, 1);
      expect(operations[0].type, 'keep');
      expect(operations[0].text, 'Plain text content');
    });

    test('applyEditOperations builds text from keep and add operations', () {
      final model = UpdateNoteRequestModel(
        noteName: 'Test Note',
        updatedNoteDescription: '''[
          {"type": "keep", "text": "Original"},
          {"type": "add", "text": " content"},
          {"type": "remove", "text": "text"},
          {"type": "add", "text": "new"}
        ]''',
      );
      final result = model.applyEditOperations('Original text');
      expect(result, 'Original contentnew');
    });

    test('applyEditOperations handles empty operations list', () {
      final model = UpdateNoteRequestModel(
        noteName: 'Test Note',
        updatedNoteDescription: '[]',
      );
      final result = model.applyEditOperations('Original text');
      expect(result, '');
    });

    test('applyEditOperations handles invalid JSON gracefully', () {
      final model = UpdateNoteRequestModel(
        noteName: 'Test Note',
        updatedNoteDescription: 'Invalid JSON',
      );
      final result = model.applyEditOperations('Original text');
      expect(result, 'Invalid JSON');
    });
  });
}
