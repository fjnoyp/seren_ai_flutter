import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_quick_actions/models/ai_quick_action.dart';

final aiQuickActionsServiceProvider =
    NotifierProvider<AIQuickActionsService, List<AIQuickAction>>(
        AIQuickActionsService.new);

class AIQuickActionsService extends Notifier<List<AIQuickAction>> {
  @override
  List<AIQuickAction> build() {
    _generateQuickActionsForCurrentPage();
    return [];
  }

  /// Adds a quick action to the list of quick actions.
  ///
  /// For eventual use from the UI.
  void addQuickAction(AIQuickAction quickAction) {
    state = [...state, quickAction];
  }

  /// Removes a quick action from the list of quick actions.
  ///
  /// For eventual use from the UI.
  void removeQuickAction(AIQuickAction quickAction) {
    state = state.where((action) => action != quickAction).toList();
  }

  /// Automatically generates quick actions for the current page.
  void _generateQuickActionsForCurrentPage() {
    ref.listen(currentRouteProvider, (prev, next) {
      final appRoute = AppRoutes.fromString(next);
      final context = ref.read(navigationServiceProvider).context;

      switch (appRoute) {
        case AppRoutes.projectDetails:
        // TODO: Add quick actions for project details page
        // We don't use break here so that we also use project page quick actions
        case AppRoutes.projects:
          state = [
            AIQuickAction.createTask(context),
            AIQuickAction.findTasks(context),
            AIQuickAction.updateTasks(context),
            // AIQuickAction.createProject(context),
          ];
          break;
        case AppRoutes.manageOrgUsers:
          state = [
            // AIQuickAction.inviteUserToOrg(context, ref.read(curOrgServiceProvider).name),
          ];
          break;
        case AppRoutes.home:
          // TODO: Add quick actions for home page
          break;
        case AppRoutes.taskPage:
          // TODO: Add quick actions for task page
          break;
        case AppRoutes.shifts:
          // TODO: Add quick actions for shifts page
          break;
        case AppRoutes.noteList:
          // TODO: Add quick actions for note list page
          break;
        case AppRoutes.notePage:
          // TODO: Add quick actions for note page
          break;
        default:
          state = [];
      }
    });
  }

  /// Sends current context data to the AI and generates quick actions based on the AI's response.
  void generateQuickActionsFromAI() {}
}
