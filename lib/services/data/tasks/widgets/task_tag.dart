import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskTag extends StatelessWidget {
  const TaskTag._({
    this.text,
    this.color,
    this.isTaskLabel = false,
    this.isPhaseLabel = false,
  });

  final String? text;
  final bool isTaskLabel;
  final bool isPhaseLabel;
  final Color? color;

  /// For a phase tag
  factory TaskTag.phase() => const TaskTag._(isPhaseLabel: true);

  /// For a task tag
  factory TaskTag.task() => const TaskTag._(isTaskLabel: true);

  /// For a custom tag (used to show the phase of a task, for example)
  factory TaskTag.custom({required String text, Color? color}) =>
      TaskTag._(text: text, color: color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
      ),
      child: Text(
        isTaskLabel
            ? AppLocalizations.of(context)!.task
            : isPhaseLabel
                ? AppLocalizations.of(context)!.phase
                : text ?? '',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
      ),
    );
  }
}
