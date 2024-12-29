import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'task_comment_model.g.dart';

@JsonSerializable()
class TaskCommentModel implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'author_user_id')
  final String authorUserId;

  @JsonKey(name: 'parent_task_id')
  final String parentTaskId;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  final String? content;

  @JsonKey(name: 'start_datetime')
  final DateTime? startDateTime;

  @JsonKey(name: 'end_datetime')
  final DateTime? endDateTime;

  TaskCommentModel({
    String? id,
    required this.authorUserId,
    required this.parentTaskId,
    this.createdAt,
    this.updatedAt,
    this.content,
    this.startDateTime,
    this.endDateTime,
  }) : id = id ?? uuid.v4();

  TaskCommentModel copyWith({
    String? id,
    String? authorUserId,
    String? parentTaskId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? content,
    DateTime? startDateTime,
    DateTime? endDateTime,
  }) {
    return TaskCommentModel(
      id: id ?? this.id,
      authorUserId: authorUserId ?? this.authorUserId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      content: content ?? this.content,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
    );
  }

  factory TaskCommentModel.fromJson(Map<String, dynamic> json) =>
      _$TaskCommentModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskCommentModelToJson(this);
}
