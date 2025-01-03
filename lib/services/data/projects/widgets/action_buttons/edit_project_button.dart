import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/selected_project_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditProjectButton extends ConsumerWidget {
  const EditProjectButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.editProjectTooltip,
      icon: const Icon(Icons.edit),
      onPressed: () {
        if (!isWebVersion) {
          // remove self from stack
          ref.read(navigationServiceProvider).pop();
        }
        openProjectPage(ref, context,
            mode: EditablePageMode.edit,
            project: ref.read(selectedProjectProvider).value!);
      },
    );
  }
}
