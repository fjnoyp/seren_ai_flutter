import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

mixin AiReadableMixin {
  Map<String, dynamic> baseAiReadableMap({
    required String type,
    required Map<String, dynamic> data,
    required UserModel? author,
    ProjectModel? project,
  }) {
    return {
      type: data,
      'author': author?.email ?? 'Unknown',
      'project': project?.name ?? 'No Project',
    };
  }
}
