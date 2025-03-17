import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskTag extends StatelessWidget {
  const TaskTag._({
    this.text,
    this.color,
    this.isTaskLabel = false,
    this.isPhaseLabel = false,
    this.outlined = false,
    this.isLarge = true,
  });

  final String? text;
  final bool isTaskLabel;
  final bool isPhaseLabel;
  final Color? color;
  final bool outlined;
  final bool isLarge;

  /// For a phase tag
  factory TaskTag.phase({bool outlined = false, bool isLarge = true}) =>
      TaskTag._(isPhaseLabel: true, outlined: outlined, isLarge: isLarge);

  /// For a task tag
  factory TaskTag.task({bool outlined = false, bool isLarge = true}) =>
      TaskTag._(isTaskLabel: true, outlined: outlined, isLarge: isLarge);

  /// For a custom tag (used to show the phase of a task, for example)
  factory TaskTag.custom({
    required String text,
    Color? color,
    bool outlined = false,
    bool isLarge = true,
  }) =>
      TaskTag._(
        text: text,
        color: color,
        outlined: outlined,
        isLarge: isLarge,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = isTaskLabel
        ? AppLocalizations.of(context)!.task
        : isPhaseLabel
            ? AppLocalizations.of(context)!.phase
            : text;
    if (label == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: isLarge
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 4)
          : const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: outlined
            ? Colors.transparent
            : color ?? Theme.of(context).colorScheme.primary,
        borderRadius: outlined
            ? BorderRadius.circular(4)
            : const BorderRadius.horizontal(left: Radius.circular(8)),
        border: outlined
            ? Border.all(
                color: color ?? theme.colorScheme.primary,
              )
            : null,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isLarge ? 200 : 80,
        ),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: (isLarge
                  ? theme.textTheme.titleSmall
                  : theme.textTheme.labelSmall)
              ?.copyWith(
            color: outlined
                ? color ?? theme.colorScheme.primary
                : theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
