import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';

abstract class BaseNavigationService {
  final Ref ref;
  BaseNavigationService(this.ref);

  NotifierProvider get idNotifierProvider;
  void setIdFunction(String id);

  static BaseNavigationService? fromAppRoute(AppRoutes route, WidgetRef ref) {
    return switch (route) {
      AppRoutes.projectOverview => ref.read(projectNavigationServiceProvider),
      AppRoutes.taskPage => ref.read(taskNavigationServiceProvider),
      AppRoutes.notePage => ref.read(notesNavigationServiceProvider),
      _ => null,
    };
  }
}
