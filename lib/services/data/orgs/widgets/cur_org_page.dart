import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/joined_user_org_roles_by_org_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/orgs_repository.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/action_buttons/edit_org_button.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/form/org_selection_fields.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/manage_org_users_page.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';

class CurOrgPage extends ConsumerWidget {
  final EditablePageMode mode;

  const CurOrgPage({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curOrgAsync = ref.watch(curSelectedOrgProvider);

    if (curOrgAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (curOrgAsync.hasError) {
      return Center(child: Text('Error: ${curOrgAsync.error}'));
    }

    final curOrg = curOrgAsync.value;
    if (curOrg == null) return const SizedBox.shrink();

    final admins = ref
            .watch(joinedUserOrgRolesByOrgStreamProvider(curOrg.id))
            .value
            ?.where((joinedOrgRole) =>
                joinedOrgRole.orgRole.orgRole == OrgRole.admin)
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
                  leading: UserAvatar(admins[index].user!),
                  title: Text(
                      '${admins[index].user!.firstName} ${admins[index].user!.lastName}'),
                );
              },
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: OutlinedButton(
                onPressed: () =>
                    openManageOrgUsersPage(context, ref, curOrg.id),
                child: Text(AppLocalizations.of(context)!.manageOrgUsers),
              ),
            ),
            const SizedBox(height: 24)
          ] else ...[
            OrgNameField(orgId: curOrg.id),
            const SizedBox(height: 8),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: OrgAddressField(orgId: curOrg.id),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    ref.read(orgsRepositoryProvider).upsertItem(curOrg);
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
