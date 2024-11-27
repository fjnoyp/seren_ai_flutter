import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_roles_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/user_org_roles_db_provider.dart';
import 'package:seren_ai_flutter/widgets/common/debug_mode_provider.dart';

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
              final joinedRole = joinedOrgRoles.valueOrNull![index];
              return ListTile(
                onTap: () {
                  if (ref.read(isDebugModeSNP)) {
                    // TODO: improve UI instead of using context menu
                    _showContextMenu(context, ref, joinedRole, Offset.zero);
                  }
                },
                title: Text(
                    '${joinedRole.user?.firstName} ${joinedRole.user?.lastName}'),
                subtitle: Text(joinedRole.orgRole.orgRole),
                /*
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Implement user removal logic here
                    },
                  ),
                  */
              );
            },
          );
  }

  void _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    JoinedUserOrgRoleModel joinedRole,
    Offset tapPosition,
  ) {
    final size = MediaQuery.of(context).size;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        size.width - tapPosition.dx,
        size.height - tapPosition.dy,
      ),
      items: [
        PopupMenuItem(
          onTap: () => ref
              .read(userOrgRolesDbProvider)
              .upsertItem(joinedRole.orgRole.copyWith(orgRole: 'admin')),
          child: const Text('Make Admin'),
        ),
        PopupMenuItem(
          onTap: () => ref
              .read(userOrgRolesDbProvider)
              .upsertItem(joinedRole.orgRole.copyWith(orgRole: 'editor')),
          child: const Text('Make Editor'),
        ),
        PopupMenuItem(
          onTap: () => ref
              .read(userOrgRolesDbProvider)
              .upsertItem(joinedRole.orgRole.copyWith(orgRole: 'member')),
          child: const Text('Make Member'),
        ),
      ],
    );
  }
}
