import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'task_comments_model.g.dart';

@JsonSerializable()
class TaskCommentsModel implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'author_user_id')
  final String authorUserId;

  @JsonKey(name: 'parent_task_id')
  final String parentTaskId;

  @JsonKey(name: 'created_date')
  final DateTime createdDate;

  final String? content;

  @JsonKey(name: 'start_date_time')
  final DateTime? startDateTime;

  @JsonKey(name: 'end_date_time')
  final DateTime? endDateTime;

  TaskCommentsModel({
    String? id, 
    required this.authorUserId,
    required this.parentTaskId,
    required this.createdDate,
    this.content,
    this.startDateTime,
    this.endDateTime,
  }) : id = id ?? uuid.v4();

  factory TaskCommentsModel.fromJson(Map<String, dynamic> json) => _$TaskCommentsModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskCommentsModelToJson(this);
}
