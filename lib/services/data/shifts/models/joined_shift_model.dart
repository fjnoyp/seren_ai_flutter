import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_model.dart';

class JoinedShiftModel {
  final ShiftModel shift;
  final ProjectModel? parentProject;

  JoinedShiftModel({
    required this.shift,
    this.parentProject,
  });
}