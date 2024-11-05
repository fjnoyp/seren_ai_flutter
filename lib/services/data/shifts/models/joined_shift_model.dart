import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_model.dart';

class JoinedShiftModel {
  final ShiftModel shift;
  final ProjectModel? parentProject;

  JoinedShiftModel({
    required this.shift,
    this.parentProject,
  });

  factory JoinedShiftModel.fromJson(Map<String, dynamic> json) {
    // Split the json into shift and project parts by checking prefixes
    final shiftJson = _extractPrefixedFields(json, 's_');
    final projectJson = _extractPrefixedFields(json, 'p_');

    return JoinedShiftModel(
      shift: ShiftModel.fromJson(shiftJson),
      parentProject: projectJson.isNotEmpty ? ProjectModel.fromJson(projectJson) : null,
    );
  }

  // Helper method to extract and clean prefixed fields
  static Map<String, dynamic> _extractPrefixedFields(Map<String, dynamic> json, String prefix) {
    final result = <String, dynamic>{};
    
    json.forEach((key, value) {
      if (key.startsWith(prefix)) {
        // Remove prefix and add to result map
        final cleanKey = key.replaceFirst(prefix, '');
        result[cleanKey] = value;
      }
    });
    
    return result;
  }
}
