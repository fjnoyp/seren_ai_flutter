import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_roles_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/user_org_roles_db_provider.dart';

class ManageOrgUsersPage extends ConsumerWidget {
  const ManageOrgUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curOrgId = ref.watch(curOrgIdProvider);

    if (curOrgId == null) {
      return Center(child: Text(AppLocalizations.of(context)!.noOrgSelected));
    }

    final joinedOrgRoles = ref.watch(joinedCurOrgRolesProvider);

    return joinedOrgRoles.valueOrNull == null
        ? Center(child: Text(AppLocalizations.of(context)!.noUsersInOrg))
        : ListView.builder(
            itemCount: joinedOrgRoles.valueOrNull!.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => _ChangeUserRoleDialog(
                        currentUserRole: joinedOrgRoles.valueOrNull![index]),
                  );
                },
                title: Text(
                    '${joinedOrgRoles.valueOrNull![index].user?.firstName} ${joinedOrgRoles.valueOrNull![index].user?.lastName}'),
                subtitle:
                    Text(joinedOrgRoles.valueOrNull![index].orgRole.orgRole),
              );
            },
          );
  }
}

class _ChangeUserRoleDialog extends HookConsumerWidget {
  const _ChangeUserRoleDialog({required this.currentUserRole});

  final JoinedUserOrgRoleModel currentUserRole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = useState(currentUserRole.orgRole.orgRole);
    final roles = ['admin', 'editor', 'member'];

    return AlertDialog(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              '${currentUserRole.user?.firstName} ${currentUserRole.user?.lastName}'),
          Text(
              '${currentUserRole.orgRole.orgRole} of ${currentUserRole.org!.name}',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
      content: ListView.builder(
        shrinkWrap: true,
        itemCount: roles.length,
        itemBuilder: (context, index) {
          return RadioListTile<String>(
            value: roles[index],
            groupValue: state.value,
            onChanged: (value) => state.value = value ?? 'member',
            title: Text(roles[index]),
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
                    itemName: '${currentUserRole.user?.firstName}',
                    onDelete: () {
                      ref
                          .read(userOrgRolesDbProvider)
                          .deleteItem(currentUserRole.orgRole.id);
                      Navigator.of(context).pop();
                    }));
          },
          child: Text(AppLocalizations.of(context)!.removeUser),
        ),
        FilledButton(
          onPressed: () {
            ref.read(userOrgRolesDbProvider).upsertItem(
                currentUserRole.orgRole.copyWith(orgRole: state.value));
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}
