import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_project_service_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_project_state_provider.dart';

class ProjectNameField extends BaseNameField {
  ProjectNameField({
    super.key,
  }) : super(
          enabled: true,
          nameProvider: curProjectStateProvider
              .select((joinedProject) => joinedProject.project.name),
          updateName: (ref, name) =>
              ref.read(curProjectServiceProvider).updateProjectName(name),
        );
}

class ProjectDescriptionSelectionField extends BaseTextBlockEditSelectionField {
  ProjectDescriptionSelectionField({super.key})
      : super(
          enabled: true,
          labelWidget: const Icon(Icons.description),
          descriptionProvider: curProjectStateProvider
              .select((joinedProject) => joinedProject.project.description ?? ''),
          updateDescription: (ref, description) => ref
              .read(curProjectServiceProvider)
              .updateDescription(description),
        );
}

class ProjectAddressField extends BaseTextBlockEditSelectionField {
  ProjectAddressField({super.key}) : super(
          enabled: true,
          labelWidget: const Icon(Icons.location_on),
          descriptionProvider: curProjectStateProvider.select(
              (joinedProject) => joinedProject.project.address ?? ''),
          updateDescription: (ref, address) => ref
              .read(curProjectServiceProvider)
              .updateAddress(address),
        );
}

