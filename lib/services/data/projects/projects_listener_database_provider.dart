import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_listener_database_notifier.dart';

final projectsListenerDatabaseProvider = StateNotifierProvider.family<BaseListenerDatabaseNotifier<ProjectModel>, List<ProjectModel>, String>((ref, parentTeamId) {
  return BaseListenerDatabaseNotifier<ProjectModel>(
    tableName: 'projects',
    eqFilters: [
      {'key': 'parent_team_id', 'value': parentTeamId},
      // Add more filters if needed
    ],
    fromJson: (json) => ProjectModel.fromJson(json),
  );
});

/*
final projectsDatabaseProvider = StateNotifierProvider.family<ProjectsDatabaseNotifier, List<ProjectModel>, String>((ref, parentTeamId) {
  return ProjectsDatabaseNotifier(parentTeamId);
});

/// Provider for interacting with Projects
class ProjectsDatabaseNotifier extends StateNotifier<List<ProjectModel>>{
  final SupabaseClient client = Supabase.instance.client;
  final String parentTeamId;

  ProjectsDatabaseNotifier(this.parentTeamId) : super([]) {
      client
        .from('projects')
        .stream(primaryKey: ['id'])
        .eq('parent_team_id', parentTeamId)
        .listen((response) {
          final projects =
              (response as List).map((e) => ProjectModel.fromJson(e)).toList();
          state = projects;
        });     
  }

  ProjectModel getProject(String projectId) {
    return state.firstWhere((element) => element.id == projectId);
  }

  Future<ProjectModel> createProject(ProjectModel project) async {
    final response = await client
        .from('projects')
        .insert(project.toJson())
        .select();
    return ProjectModel.fromJson(response.first);
  }

  Future<void> modifyProject(ProjectModel project) async {
    await client
        .from('projects')
        .upsert(project.toJson())
        .select();
  }

  Future<void> deleteProject(ProjectModel project) async {
    await client
        .from('projects')
        .delete()
        .eq('id', project.id);        
  }
}
*/