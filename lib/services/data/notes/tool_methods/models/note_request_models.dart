import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_info_request_model.dart';

class CreateNoteRequestModel extends AiActionRequestModel {
  final String noteName;
  final String noteDescription;

  CreateNoteRequestModel({
    required this.noteName,
    required this.noteDescription,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.createNote);

  static CreateNoteRequestModel fromJson(Map<String, dynamic> json) {
    return CreateNoteRequestModel(
      args: json['args'],
      noteName: json['args']['note_name'],
      noteDescription: json['args']['note_description'],
    );
  }
}

class UpdateNoteRequestModel extends AiActionRequestModel {
  final String noteName;
  final String updatedNoteDescription;

  UpdateNoteRequestModel({
    required this.noteName,
    required this.updatedNoteDescription,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.updateNote);

  static UpdateNoteRequestModel fromJson(Map<String, dynamic> json) {
    return UpdateNoteRequestModel(
      args: json['args'],
      noteName: json['args']['note_name'],
      updatedNoteDescription: json['args']['updated_note_description'],
    );
  }
}

class ShareNoteRequestModel extends AiActionRequestModel {
  final String noteName;

  ShareNoteRequestModel({
    required this.noteName,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.shareNote);

  static ShareNoteRequestModel fromJson(Map<String, dynamic> json) {
    return ShareNoteRequestModel(
      args: json['args'],
      noteName: json['args']['note_name'],
    );
  }
}

class DeleteNoteRequestModel extends AiActionRequestModel {
  final String noteName;

  DeleteNoteRequestModel({
    required this.noteName,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.deleteNote);

  static DeleteNoteRequestModel fromJson(Map<String, dynamic> json) {
    return DeleteNoteRequestModel(
      args: json['args'],
      noteName: json['args']['note_name'],
    );
  }
}

class ShowNotesRequestModel extends AiActionRequestModel {
  final String? noteName;

  ShowNotesRequestModel({
    this.noteName,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.showNotes);

  static ShowNotesRequestModel fromJson(Map<String, dynamic> json) {
    return ShowNotesRequestModel(
      args: json['args'],
      noteName: json['args']['note_name'],
    );
  }
}

class FindNotesRequestModel extends AiInfoRequestModel {
  final String? noteName;
  final String? noteCreatedDateStart;
  final String? noteCreatedDateEnd;
  final String? noteUpdatedDateStart;
  final String? noteUpdatedDateEnd;

  FindNotesRequestModel({
    this.noteName,
    this.noteCreatedDateStart,
    this.noteCreatedDateEnd,
    this.noteUpdatedDateStart,
    this.noteUpdatedDateEnd,
    super.showUI = true,
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
    );
  }
}
