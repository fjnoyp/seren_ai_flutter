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
}
