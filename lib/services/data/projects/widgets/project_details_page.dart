import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_project_service_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_project_state_provider.dart';

class ProjectDetailsPage extends HookConsumerWidget {
  const ProjectDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProjectNameField(),
        const SizedBox(height: 16),
        ProjectDescriptionSelectionField(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              ref.read(curProjectServiceProvider).saveProject();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
            child: const Text('Update Project'),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class ProjectNameField extends BaseNameField {
  ProjectNameField({
    super.key,
  }) : super(
          enabled: true,
          nameProvider: curProjectStateProvider
              .select((state) => state.value?.name ?? ''),
          updateName: (ref, name) =>
              ref.read(curProjectServiceProvider).updateProjectName(name),
        );
}

class ProjectDescriptionSelectionField extends BaseTextBlockEditSelectionField {
  ProjectDescriptionSelectionField({super.key})
      : super(
          enabled: true,
          descriptionProvider: curProjectStateProvider
              .select((state) => state.value?.description ?? ''),
          updateDescription: (ref, description) => ref
              .read(curProjectServiceProvider)
              .updateProjectDescription(description),
        );
}
