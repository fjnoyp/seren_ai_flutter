import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_role_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/joined_user_org_roles_by_org_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/user_org_roles_repository.dart';

import 'package:seren_ai_flutter/services/data/orgs/widgets/action_buttons/invite_user_to_org_button.dart';

class ManageOrgUsersPage extends ConsumerWidget {
  const ManageOrgUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curOrgId = ref.watch(curSelectedOrgIdNotifierProvider);

    if (curOrgId == null) {
      return Center(child: Text(AppLocalizations.of(context)!.noOrgSelected));
    }

    final joinedOrgRoles =
        ref.watch(joinedUserOrgRolesByOrgStreamProvider(curOrgId));

    return joinedOrgRoles.valueOrNull == null
        ? Center(child: Text(AppLocalizations.of(context)!.noUsersInOrg))
        : ListView.builder(
            itemCount: joinedOrgRoles.valueOrNull!.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ChangeUserRoleDialog(
                        currentUserRole: joinedOrgRoles.valueOrNull![index]),
                  );
                },
                title: Text(
                    '${joinedOrgRoles.valueOrNull![index].user?.firstName} ${joinedOrgRoles.valueOrNull![index].user?.lastName}'),
                subtitle: Text(joinedOrgRoles
                    .valueOrNull![index].orgRole.orgRole
                    .toHumanReadable(context)),
              );
            },
          );
  }
}

class ChangeUserRoleDialog extends HookConsumerWidget {
  const ChangeUserRoleDialog({super.key, required this.currentUserRole});

  final JoinedUserOrgRoleModel currentUserRole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = useState(currentUserRole.orgRole.orgRole);

    return AlertDialog(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              '${currentUserRole.user?.firstName} ${currentUserRole.user?.lastName}'),
          Text(
              AppLocalizations.of(context)!.userRoleOfOrg(
                  currentUserRole.orgRole.orgRole.toHumanReadable(context),
                  currentUserRole.org!.name),
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
      content: ListView.builder(
        shrinkWrap: true,
        itemCount: OrgRole.values.length,
        itemBuilder: (context, index) {
          return RadioListTile<OrgRole>(
            value: OrgRole.values[index],
            groupValue: state.value,
            onChanged: (value) => state.value = value ?? OrgRole.member,
            title: Text(OrgRole.values[index].toHumanReadable(context)),
          );
        },
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () {
            showDialog(
                context: context,
                // TODO: Externalize confirmation dialog's content
                // to use a more proper message here
                builder: (context) => DeleteConfirmationDialog(
                    itemName: '${currentUserRole.user.firstName}',
                    onDelete: () {
                      ref
                          .read(userOrgRolesRepositoryProvider)
                          .deleteItem(currentUserRole.orgRole.id);
                      Navigator.of(context).pop();
                    }));
          },
          child: Text(AppLocalizations.of(context)!.removeUser),
        ),
        FilledButton(
          onPressed: () {
            ref.read(userOrgRolesRepositoryProvider).upsertItem(
                currentUserRole.orgRole.copyWith(orgRole: state.value));
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}

void openManageOrgUsersPage(BuildContext context, WidgetRef ref) {
  Navigator.pushNamed(context, AppRoutes.manageOrgUsers.name, arguments: {
    'actions': [
      if (ref.read(curUserOrgRoleProvider).value == OrgRole.admin)
        const InviteUserToOrgButton()
    ],
  });
}
