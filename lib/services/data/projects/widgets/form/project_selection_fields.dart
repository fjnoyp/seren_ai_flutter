import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/editing_project_service_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProjectNameField extends BaseNameField {
  ProjectNameField({
    super.key,
  }) : super(
          isEditable: true,
          nameProvider: editingProjectServiceProvider
              .select((joinedProject) => joinedProject.project.name),
          updateName: (ref, name) => ref
              .read(editingProjectServiceProvider.notifier)
              .updateProject(name: name),
        );
}

class ProjectDescriptionSelectionField extends BaseTextBlockEditSelectionField {
  ProjectDescriptionSelectionField(BuildContext context, {super.key})
      : super(
          isEditable: true,
          labelWidget: const Icon(Icons.description),
          hintText: AppLocalizations.of(context)!.enterProjectDescription,
          descriptionProvider: editingProjectServiceProvider.select(
              (joinedProject) => joinedProject.project.description ?? ''),
          updateDescription: (ref, description) => ref
              .read(editingProjectServiceProvider.notifier)
              .updateProject(description: description),
        );
}

class ProjectAddressField extends BaseTextBlockEditSelectionField {
  ProjectAddressField(BuildContext context, {super.key})
      : super(
          isEditable: true,
          labelWidget: const Icon(Icons.location_on),
          hintText: AppLocalizations.of(context)!.enterProjectAddress,
          descriptionProvider: editingProjectServiceProvider
              .select((joinedProject) => joinedProject.project.address ?? ''),
          updateDescription: (ref, address) => ref
              .read(editingProjectServiceProvider.notifier)
              .updateProject(address: address),
        );
}
