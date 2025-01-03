import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/cur_org_page.dart';

class EditOrgButton extends ConsumerWidget {
  const EditOrgButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        // remove self from stack
        ref.read(navigationServiceProvider).pop();
        openOrgPage(ref, mode: EditablePageMode.edit);
      },
    );
  }
}
