import 'package:seren_ai_flutter/services/ai/langgraph/models/lg_agent_state_model.dart';

/// Represents the command parameter for thread run operations
class LgCommandModel {
  final Map<String, dynamic> command;

  LgCommandModel._({
    required this.command,
  });

  /// Resume a run that was paused with the provided value
  factory LgCommandModel.resume(String value) {
    return LgCommandModel._(command: {
      "resume": value,
    });
  }

  /// Update an existing and running run
  /// Can optionally include new input
  factory LgCommandModel.update({LgAgentStateModel? input}) {
    final updateMap = <String, dynamic>{};
    if (input != null) {
      updateMap["input"] = input.toJson();
    }

    return LgCommandModel._(command: {
      "update": updateMap,
    });
  }

  /// Send input to a run that is awaiting input
  factory LgCommandModel.send(
      {required String node, required LgAgentStateModel input}) {
    return LgCommandModel._(command: {
      "send": {
        "node": node,
        "input": input.toJson(),
      }
    });
  }

  Map<String, dynamic> toJson() {
    return command;
  }
}
