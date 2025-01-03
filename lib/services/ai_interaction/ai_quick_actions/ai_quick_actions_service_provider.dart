import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_quick_actions/models/ai_quick_action.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_service_provider.dart';

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

      switch (appRoute) {
        case AppRoutes.projectDetails:
        // TODO: Add quick actions for project details page
        // We don't use break here so that we also use project page quick actions
        case AppRoutes.projects:
          state = [
            AIQuickAction(
                description: 'Ask AI for a new project',
                userInputHint: 'Please create a project named [project name]',
                aiFollowUpQuestions: [
                  'What is the project about?',
                  'Where is the project located?',
                ]),
          ];
          break;
        case AppRoutes.manageOrgUsers:
          final org = ref.read(curOrgServiceProvider);
          state = [
            AIQuickAction(
                description: 'Invite someone',
                userInputHint:
                    'Invite [user@example.com] as a member to ${org.name}'),
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
