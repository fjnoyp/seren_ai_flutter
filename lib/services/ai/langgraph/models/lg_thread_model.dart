/// Represents a thread in the Langgraph API
class LgThreadModel {
  final String threadId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  final String status;
  //final Map<String, dynamic> values;

  LgThreadModel({
    required this.threadId,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
    required this.status,
    //required this.values,
  });

  factory LgThreadModel.fromJson(Map<String, dynamic> json) {
    return LgThreadModel(
      threadId: json['thread_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
      status: json['status'] as String,
      // Ignore for now - contains all messages of thread n
      //values: json['values'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thread_id': threadId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
      'status': status,
      //'values': values,
    };
  }
}
