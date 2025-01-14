import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/org_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/orgs_repository.dart';

class OrgNameField extends BaseNameField {
  final String orgId;

  OrgNameField({
    super.key,
    required this.orgId,
  }) : super(
          isEditable: true,
          nameProvider: orgStreamProvider(orgId)
              .select((org) => org.value?.name ?? 'loading...'),
          updateName: (ref, name) =>
              ref.read(orgsRepositoryProvider).updateOrgName(orgId, name),
        );
}

class OrgAddressField extends BaseTextBlockEditSelectionField {
  final String orgId;

  OrgAddressField({
    super.key,
    required this.orgId,
  }) : super(
          isEditable: true,
          labelWidget: const Icon(Icons.location_on),
          descriptionProvider: orgStreamProvider(orgId)
              .select((org) => org.value?.address ?? ''),
          updateDescription: (ref, address) => ref
              .read(orgsRepositoryProvider)
              .updateOrgAddress(orgId, address!),
        );
}
