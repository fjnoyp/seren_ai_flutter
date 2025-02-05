import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_quick_actions/models/ai_quick_action.dart';

final aiQuickActionsServiceProvider =
    NotifierProvider<AiQuickActionsService, List<AiQuickAction>>(
        AiQuickActionsService.new);

class AiQuickActionsService extends Notifier<List<AiQuickAction>> {
  @override
  List<AiQuickAction> build() {
    _generateQuickActionsForCurrentPage();
    return [];
  }

  /// Adds a quick action to the list of quick actions.
  ///
  /// For eventual use from the UI.
  void addQuickAction(AiQuickAction quickAction) {
    state = [...state, quickAction];
  }

  /// Removes a quick action from the list of quick actions.
  ///
  /// For eventual use from the UI.
  void removeQuickAction(AiQuickAction quickAction) {
    state = state.where((action) => action != quickAction).toList();
  }

  /// Automatically generates quick actions for the current page.
  void _generateQuickActionsForCurrentPage() {
    ref.listen(currentRouteProvider, (prev, next) {
      final appRoute = AppRoutes.getAppRouteFromPath(next);
      final context = ref.read(navigationServiceProvider).context;

      switch (appRoute) {
        case AppRoutes.projectDetails:
        // TODO p3: Add quick actions for project details page
        // We don't use break here so that we also use project page quick actions
        case AppRoutes.projects:
          state = [
            AiQuickAction.createTask(context),
            AiQuickAction.findTasks(context),
            // AiQuickAction.createProject(context),
          ];
          break;
        case AppRoutes.manageOrgUsers:
          state = [
            // AiQuickAction.inviteUserToOrg(context, ref.read(curOrgServiceProvider).name),
          ];
          break;
        case AppRoutes.home:
          state = [
            AiQuickAction.checkOverdueTasks(context),
            AiQuickAction.getMyShiftLogs(context),
          ];
          break;
        case AppRoutes.taskPage:
          state = [
            AiQuickAction.updateTask(context),
          ];
          break;
        case AppRoutes.shifts:
          // TODO p3: Add quick actions for shifts page
          break;
        case AppRoutes.noteList:
          // TODO p3: Add quick actions for note list page
          break;
        case AppRoutes.notePage:
          // TODO p3: Add quick actions for note page
          break;
        default:
          state = [];
      }
    });
  }

  /// Sends current context data to the AI and generates quick actions based on the AI's response.
  void generateQuickActionsFromAi() {}
}
