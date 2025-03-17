import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/org_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/orgs_repository.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/user_org_roles_repository.dart';

class DeleteOrgButton extends ConsumerWidget {
  const DeleteOrgButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgId = ref.watch(curSelectedOrgIdNotifierProvider);
    if (orgId == null) return const SizedBox.shrink();

    return IconButton(
      tooltip: AppLocalizations.of(context)!.deleteProjectTooltip,
      icon: const Icon(Icons.delete),
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return AsyncValueHandlerWidget(
              value: ref.watch(orgStreamProvider(orgId)),
              data: (org) => org != null
                  ? DeleteConfirmationDialog(
                      itemName: org.name,
                      onDelete: () async {
                        final orgsRepository = ref.read(orgsRepositoryProvider);

                        await ref
                            .read(userOrgRolesRepositoryProvider)
                            .removeAllOrgRolesForOrg(orgId);

                        // we don't want to delete the org,
                        // we just want to disable it after removing all users from it
                        orgsRepository
                            .updateItem(org.copyWith(isEnabled: false));
                      },
                    )
                  : const Center(child: Text('Error: could not find org')),
            );
          },
        );
      },
    );
  }
}
