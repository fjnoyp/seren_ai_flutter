import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_page.dart';

class EditProjectButton extends ConsumerWidget {
  const EditProjectButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        // remove self from stack
        Navigator.pop(context);
        openProjectPage(ref, context, mode: EditablePageMode.edit);
      },
    );
  }
}
