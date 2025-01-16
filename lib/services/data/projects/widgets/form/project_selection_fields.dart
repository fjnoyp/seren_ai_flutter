import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';

class ProjectNameField extends BaseNameField {
  final String projectId;

  ProjectNameField(
    this.projectId, {
    super.key,
  }) : super(
          isEditable: true,
          nameProvider: projectByIdStreamProvider(projectId)
              .select((project) => project.value?.name ?? 'loading...'),
          updateName: (ref, name) => ref
              .read(projectsRepositoryProvider)
              .updateProjectName(projectId, name),
        );
}

class ProjectDescriptionSelectionField extends BaseTextBlockEditSelectionField {
  final String projectId;

  ProjectDescriptionSelectionField(
    this.projectId,
    BuildContext context, {
    super.key,
  }) : super(
          isEditable: true,
          labelWidget: const Icon(Icons.description),
          hintText: AppLocalizations.of(context)!.enterProjectDescription,
          descriptionProvider: projectByIdStreamProvider(projectId)
              .select((project) => project.value?.description ?? ''),
          updateDescription: (ref, description) => ref
              .read(projectsRepositoryProvider)
              .updateProjectDescription(projectId, description ?? ''),
        );
}

class ProjectAddressField extends BaseTextBlockEditSelectionField {
  final String projectId;

  ProjectAddressField(this.projectId, BuildContext context, {super.key})
      : super(
          isEditable: true,
          labelWidget: const Icon(Icons.location_on),
          hintText: AppLocalizations.of(context)!.enterProjectAddress,
          descriptionProvider: projectByIdStreamProvider(projectId)
              .select((project) => project.value?.address ?? ''),
          updateDescription: (ref, address) => ref
              .read(projectsRepositoryProvider)
              .updateProjectAddress(projectId, address ?? ''),
        );
}
