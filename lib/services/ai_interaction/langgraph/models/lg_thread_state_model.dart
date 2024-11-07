// Model to represent thread state with focus on messages
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_base_message_model.dart';

class LgThreadStateModel {
  final List<LgAiBaseMessageModel> messages;
  final Map<String, dynamic> otherValues;

  LgThreadStateModel({
    required this.messages,
    required this.otherValues,
  });

  factory LgThreadStateModel.fromJson(Map<String, dynamic> json) {
    final values = json['values'] as Map<String, dynamic>;
    final messagesList = values['messages'] as List;

    return LgThreadStateModel(
      messages: messagesList
          .map((msg) => LgAiBaseMessageModel.fromJson(msg as Map<String, dynamic>))
          .toList(),
      otherValues: Map<String, dynamic>.from(values)..remove('messages'),
    );
  }

  Map<String, dynamic> toJson() => {
        'values': {
          'messages': messages
              .map((m) => {
                    'content': m.content,
                    'type': m.type.toString().split('.').last,
                  })
              .toList(),
          ...otherValues,
        }
      };
}