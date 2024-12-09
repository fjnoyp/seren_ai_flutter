import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_service_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_roles_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/action_buttons/edit_org_button.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/form/org_selection_fields.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CurOrgPage extends ConsumerWidget {
  final EditablePageMode mode;

  const CurOrgPage({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curOrg = ref.watch(curOrgProvider);

    final admins = ref
            .watch(joinedCurOrgRolesProvider)
            .value
            ?.where((role) => role.orgRole.orgRole == 'admin')
            .toList() ??
        [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mode == EditablePageMode.readOnly) ...[
            Text(
              curOrg.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (curOrg.address != null) Text(curOrg.address!),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.admins,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            ListView.builder(
              shrinkWrap: true,
              itemCount: admins.length,
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    // TODO p5: use avatar url instead
                    child: Text(
                        '${admins[index].user!.firstName[0]}${admins[index].user!.lastName[0]}'),
                  ),
                  title: Text(
                      '${admins[index].user!.firstName} ${admins[index].user!.lastName}'),
                );
              },
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.manageOrgUsers.name);
                },
                child: Text(AppLocalizations.of(context)!.manageOrgUsers),
              ),
            ),
            const SizedBox(height: 24)
          ] else ...[
            OrgNameField(),
            const SizedBox(height: 8),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: OrgAddressField(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    ref.read(curOrgProvider.notifier).saveOrg();
                    Navigator.pop(context);
                    openOrgPage(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

void openOrgPage(BuildContext context,
    {EditablePageMode mode = EditablePageMode.readOnly}) {
  final actions = [
    if (mode == EditablePageMode.readOnly) const EditOrgButton()
  ];

  Navigator.pushNamed(context, AppRoutes.organization.name,
      arguments: {'mode': mode, 'actions': actions});
}
