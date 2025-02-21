// Model to represent thread state with focus on messages

import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_ai_base_message_model.dart';

class LgThreadStateModel {
  final List<LgAiBaseMessageModel> messages;
  final Map<String, dynamic>? otherValues;

  LgThreadStateModel({
    required this.messages,
    this.otherValues,
  });

  factory LgThreadStateModel.fromJson(Map<String, dynamic> json) {
    final values = json['values'] as Map<String, dynamic>;
    final messagesList = values['messages'] as List;

//     print('\n\n\n');

// final jsonString = JsonEncoder.withIndent('  ').convert(json);
//     const int chunkSize = 1000;
//     print('\n=== START JSON ===\n');
//     for (var i = 0; i < jsonString.length; i += chunkSize) {
//       print(jsonString.substring(i, min(i + chunkSize, jsonString.length)));
//     }
//     print('\n=== END JSON ===\n');
//     print('\n\n\n');

    return LgThreadStateModel(
      messages: messagesList
          .map((msg) =>
              LgAiBaseMessageModel.fromJson(msg as Map<String, dynamic>))
          .toList(),
      otherValues: Map<String, dynamic>.from(values)..remove('messages'),
    );
  }

  Map<String, dynamic> toJson() => {
        'values': {
          'messages': messages.map((m) => m.toJson()).toList(),
        },
        //..addAll(otherValues),
      };
}
