import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_org_id_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/user_org_roles/joined_user_org_roles_listener_fam_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ManageOrgUsersPage extends ConsumerWidget {
  const ManageOrgUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curOrgId = ref.watch(curOrgIdProvider);

    if(curOrgId == null){
      return Center(child: Text(AppLocalizations.of(context)!.noOrgSelected));
    }

    final joinedOrgRoles = ref.watch(joinedUserOrgRolesListenerFamProvider(curOrgId));

    return joinedOrgRoles == null || joinedOrgRoles.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.noUsersInOrg))
          : ListView.builder(
              itemCount: joinedOrgRoles.length,
              itemBuilder: (context, index) {
                final joinedRole = joinedOrgRoles[index];
                return ListTile(
                  title: Text(joinedRole.user?.email ?? AppLocalizations.of(context)!.noEmailFound),
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
}
