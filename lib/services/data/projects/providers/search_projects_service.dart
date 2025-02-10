import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';

final searchProjectsServiceProvider =
    Provider<SearchProjectsService>((ref) => SearchProjectsService(ref));

class SearchProjectsService {
  final Ref ref;

  SearchProjectsService(this.ref);

  Future<String?> selectProject(String? projectName) async {
    if (projectName == null) {
      return await ref
          .read(curSelectedProjectIdNotifierProvider.notifier)
          .getSelectedProjectOrDefault();
    }

    String? selectedProjectId;
    if (projectName.isNotEmpty) {
      final selectedOrgId = ref.read(curSelectedOrgIdNotifierProvider);
      if (selectedOrgId == null) {
        return null; // Return null on error case
      }

      final projects =
          await ref.read(projectsRepositoryProvider).searchProjectsByName(
                searchQuery: projectName,
                orgId: selectedOrgId,
              );

      if (projects.isNotEmpty) {
        selectedProjectId = projects.first.id;
      }
    }

    selectedProjectId ??= await ref
        .read(curSelectedProjectIdNotifierProvider.notifier)
        .getSelectedProjectOrDefault();

    return selectedProjectId;
  }
}
    // === END SELECT PROJECT ===