import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AiQuickAction {
  /// The description of the quick action.
  ///
  /// Please keep it short and concise - to avoid obstructing the user's view.
  final String description;

  /// The user input hint for the quick action.
  ///
  /// You can include placeholders in the hint using square brackets
  /// to allow the user to fill in the missing information before sending the message.
  /// Use at most 1 placeholder per hint.
  final String userInputHint;

  /// The follow-up questions for the quick action.
  ///
  /// These questions will be asked to the user after the quick action is executed.
  /// (Not implemented yet)
  final List<String>? aiFollowUpQuestions;

  AiQuickAction({
    required this.description,
    required this.userInputHint,
    this.aiFollowUpQuestions,
  });

  factory AiQuickAction.createTask(BuildContext context) => AiQuickAction(
        description: AppLocalizations.of(context)!.askAIForNewTask,
        userInputHint: AppLocalizations.of(context)!.askAIForNewTaskHint,
        aiFollowUpQuestions: [
          AppLocalizations.of(context)!.followUpTaskDescription,
          AppLocalizations.of(context)!.followUpTaskPriority,
          AppLocalizations.of(context)!.followUpTaskDueDate,
          AppLocalizations.of(context)!.followUpTaskEstimatedDurationMinutes,
        ],
      );

  factory AiQuickAction.findTasks(BuildContext context) => AiQuickAction(
        description: AppLocalizations.of(context)!.findTasks,
        userInputHint: AppLocalizations.of(context)!.findTasksHint,
      );

  factory AiQuickAction.updateTask(BuildContext context) => AiQuickAction(
        description: AppLocalizations.of(context)!.updateTask,
        userInputHint: AppLocalizations.of(context)!.updateTaskHint,
      );

  factory AiQuickAction.checkOverdueTasks(BuildContext context) =>
      AiQuickAction(
        description: AppLocalizations.of(context)!.checkOverdueTasks,
        userInputHint: AppLocalizations.of(context)!.checkOverdueTasksHint,
      );

  factory AiQuickAction.getMyShiftAssignments(BuildContext context) =>
      AiQuickAction(
        description: AppLocalizations.of(context)!.getMyShiftAssignments,
        userInputHint: AppLocalizations.of(context)!.getMyShiftAssignmentsHint,
      );

  factory AiQuickAction.getMyShiftLogs(BuildContext context) => AiQuickAction(
        description: AppLocalizations.of(context)!.getMyShiftLogs,
        userInputHint: AppLocalizations.of(context)!.getMyShiftLogsHint,
      );

  // factory AiQuickAction.createProject(BuildContext context) => AiQuickAction(
  //       description: AppLocalizations.of(context)!.askAIForNewProject,
  //       userInputHint: AppLocalizations.of(context)!.askAIForNewProjectHint,
  //       aiFollowUpQuestions: [
  //         AppLocalizations.of(context)!.followUpProjectDescription,
  //         AppLocalizations.of(context)!.followUpProjectLocation,
  //       ],
  //     );

  // factory AiQuickAction.inviteUserToOrg(BuildContext context, String orgName) =>
  //     AiQuickAction(
  //       description: AppLocalizations.of(context)!.inviteSomeone,
  //       userInputHint: AppLocalizations.of(context)!.inviteSomeoneHint(orgName),
  //     );
}
