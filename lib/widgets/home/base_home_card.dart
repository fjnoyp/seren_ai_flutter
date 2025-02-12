import 'package:flutter/material.dart';

class BaseHomeCard extends StatelessWidget {
  final Widget child;
  // final Color color;
  final String title;
  final IconButton? cornerButton;

  const BaseHomeCard({
    super.key,
    required this.child,
    // required this.color,
    required this.title,
    this.cornerButton,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      margin: const EdgeInsets.all(2),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (cornerButton != null) cornerButton!,
              ],
            ),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class BaseHomeInnerCard extends StatelessWidget {
  final Widget child;
  final bool outlined;

  const BaseHomeInnerCard._({
    required this.child,
    required this.outlined,
  });

  factory BaseHomeInnerCard.outlined({required Widget child}) =>
      BaseHomeInnerCard._(outlined: true, child: child);

  factory BaseHomeInnerCard.filled({required Widget child}) =>
      BaseHomeInnerCard._(outlined: false, child: child);

  @override
  Widget build(BuildContext context) {
    return outlined
        ? Card.outlined(
            shape: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            child: child,
          )
        : Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: child,
          );
  }
}
