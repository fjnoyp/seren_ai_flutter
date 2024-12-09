import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/cur_org_page.dart';

class EditOrgButton extends ConsumerWidget {
  const EditOrgButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        // remove self from stack
        Navigator.pop(context);
        openOrgPage(context, mode: EditablePageMode.edit);
      },
    );
  }
}
