/// Represents a single edit operation for note content
class NoteEditOperation {
  /// Type of operation: "keep", "add", or "remove"
  final String type;

  /// Text content associated with this operation
  final String text;

  const NoteEditOperation({
    required this.type,
    required this.text,
  });

  factory NoteEditOperation.fromJson(Map<String, dynamic> json) {
    return NoteEditOperation(
      type: json['type'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
    };
  }
}
