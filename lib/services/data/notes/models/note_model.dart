import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'note_model.g.dart';

@JsonSerializable()
class NoteModel implements IHasId {
  @override
  final String id;
  final String name;

  @JsonKey(name: 'author_user_id')
  final String authorUserId;
  
  final DateTime? date;
  final String? address;
  final String? description;
  final String? actionRequired;
  final String? status;
  
  @JsonKey(name: 'parent_note_folder_id')
  final String? parentNoteFolderId;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  NoteModel({
    String? id,
    required this.name,
    required this.authorUserId,
    this.date,
    this.address,
    this.description,
    this.actionRequired,
    this.status,
    this.parentNoteFolderId,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  factory NoteModel.defaultNote() {
    final now = DateTime.now().toUtc();
    return NoteModel(
      name: 'New Note',
      authorUserId: '',  // This should be set to the current user's ID in practice
      date: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  NoteModel copyWith({
    String? id,
    String? name,
    String? authorUserId,
    DateTime? date,
    String? address,
    String? description,
    String? actionRequired,
    String? status,
    String? parentNoteFolderId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      name: name ?? this.name,
      authorUserId: authorUserId ?? this.authorUserId,
      date: date ?? this.date,
      address: address ?? this.address,
      description: description ?? this.description,
      actionRequired: actionRequired ?? this.actionRequired,
      status: status ?? this.status,
      parentNoteFolderId: parentNoteFolderId ?? this.parentNoteFolderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) => _$NoteModelFromJson(json);
  Map<String, dynamic> toJson() => _$NoteModelToJson(this);
}