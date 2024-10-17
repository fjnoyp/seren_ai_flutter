import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';

// Provide all projects for a given organization
final projectsListenerFamProvider = NotifierProvider.family<ProjectsListenerNotifier, List<ProjectModel>?, String>(
  ProjectsListenerNotifier.new
);

/// Get the projects for a specific organization
class ProjectsListenerNotifier extends FamilyNotifier<List<ProjectModel>?, String> {

  @override
  List<ProjectModel>? build(String arg) {
    String orgId = arg;
    
    final db = ref.read(dbProvider);

    final query = "SELECT * FROM projects WHERE parent_org_id = '$orgId'";

    final subscription = db.watch(query).listen((results) {
      List<ProjectModel> items = results.map((e) => ProjectModel.fromJson(e)).toList();
      state = items;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }  
}
