import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CollapsableText extends HookWidget {
  const CollapsableText(
    this.content, {
    super.key,
    this.alignment = AlignmentDirectional.centerStart,
  });

  final String content;
  final AlignmentDirectional alignment;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);
    return Flexible(
        child: content.length > 200 && !isExpanded.value
            ? Wrap(
                children: [
                  Text('${content.substring(0, 200)}...',
                      textAlign: switch (alignment) {
                        AlignmentDirectional.topStart ||
                        AlignmentDirectional.centerStart ||
                        AlignmentDirectional.bottomStart =>
                          TextAlign.left,
                        AlignmentDirectional.topEnd ||
                        AlignmentDirectional.centerEnd ||
                        AlignmentDirectional.bottomEnd =>
                          TextAlign.right,
                        _ => TextAlign.center,
                      }),
                  Align(
                    alignment: alignment,
                    child: TextButton(
                      child: const Text('Show more'),
                      onPressed: () => isExpanded.value = true,
                    ),
                  ),
                ],
              )
            : Text(content));
  }
}
