
/// Represents a single run 
class LgRunModel {
  final String runId;
  final String threadId;
  final String assistantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  final String status;
  final Map<String, dynamic> kwargs;

  LgRunModel({
    required this.runId,
    required this.threadId,
    required this.assistantId,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
    required this.status,
    required this.kwargs,
  });

  factory LgRunModel.fromJson(Map<String, dynamic> json) {
    return LgRunModel(
      runId: json['run_id'] as String,
      threadId: json['thread_id'] as String,
      assistantId: json['assistant_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
      status: json['status'] as String,
      kwargs: json['kwargs'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'run_id': runId,
      'thread_id': threadId,
      'assistant_id': assistantId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
      'status': status,
      'kwargs': kwargs,
    };
  }
}