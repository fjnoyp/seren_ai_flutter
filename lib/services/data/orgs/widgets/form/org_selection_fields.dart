import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_service_provider.dart';

class OrgNameField extends BaseNameField {
  OrgNameField({
    super.key,
  }) : super(
          isEditable: true,
          nameProvider: curOrgServiceProvider.select((org) => org.name),
          updateName: (ref, name) =>
              ref.read(curOrgServiceProvider.notifier).updateOrgName(name),
        );
}

class OrgAddressField extends BaseTextBlockEditSelectionField {
  OrgAddressField({super.key})
      : super(
          isEditable: true,
          labelWidget: const Icon(Icons.location_on),
          descriptionProvider:
              curOrgServiceProvider.select((org) => org.address ?? ''),
          updateDescription: (ref, address) =>
              ref.read(curOrgServiceProvider.notifier).updateAddress(address),
        );
}
