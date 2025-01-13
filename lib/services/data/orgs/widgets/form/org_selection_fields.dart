import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/org_invite_service_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/selected_org_id_notifier.dart';

class OrgNameField extends BaseNameField {
  OrgNameField({
    super.key,
  }) : super(
          isEditable: true,
          nameProvider: curSelectedOrgProvider
              .select((asyncValue) => asyncValue.value?.name ?? 'loading...'),
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
