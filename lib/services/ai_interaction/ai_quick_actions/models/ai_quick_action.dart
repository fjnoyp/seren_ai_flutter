import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AIQuickAction {
  /// The description of the quick action.
  ///
  /// Please keep it short and concise - to avoid obstructing the user's view.
  final String description;

  /// The user input hint for the quick action.
  ///
  /// You can include placeholders in the hint using square brackets.
  final String userInputHint;

  /// The follow-up questions for the quick action.
  ///
  /// These questions will be asked to the user after the quick action is executed.
  /// (Not implemented yet)
  final List<String>? aiFollowUpQuestions;

  AIQuickAction({
    required this.description,
    required this.userInputHint,
    this.aiFollowUpQuestions,
  });

  factory AIQuickAction.createTask(BuildContext context) => AIQuickAction(
        description: AppLocalizations.of(context)!.askAIForNewTask,
        userInputHint: AppLocalizations.of(context)!.askAIForNewTaskHint,
        aiFollowUpQuestions: [
          AppLocalizations.of(context)!.followUpTaskDescription,
          AppLocalizations.of(context)!.followUpTaskPriority,
          AppLocalizations.of(context)!.followUpTaskDueDate,
          AppLocalizations.of(context)!.followUpTaskEstimatedDurationMinutes,
        ],
      );

  factory AIQuickAction.findTasks(BuildContext context) => AIQuickAction(
        description: AppLocalizations.of(context)!.findTasks,
        userInputHint: AppLocalizations.of(context)!.findTasksHint,
      );

  factory AIQuickAction.updateTasks(BuildContext context) => AIQuickAction(
        description: AppLocalizations.of(context)!.updateTasks,
        userInputHint: AppLocalizations.of(context)!.updateTasksHint,
      );

  // factory AIQuickAction.createProject(BuildContext context) => AIQuickAction(
  //       description: AppLocalizations.of(context)!.askAIForNewProject,
  //       userInputHint: AppLocalizations.of(context)!.askAIForNewProjectHint,
  //       aiFollowUpQuestions: [
  //         AppLocalizations.of(context)!.followUpProjectDescription,
  //         AppLocalizations.of(context)!.followUpProjectLocation,
  //       ],
  //     );

  // factory AIQuickAction.inviteUserToOrg(BuildContext context, String orgName) =>
  //     AIQuickAction(
  //       description: AppLocalizations.of(context)!.inviteSomeone,
  //       userInputHint: AppLocalizations.of(context)!.inviteSomeoneHint(orgName),
  //     );
}
