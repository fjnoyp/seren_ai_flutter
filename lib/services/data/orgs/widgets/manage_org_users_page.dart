import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_roles_provider.dart';

class ManageOrgUsersPage extends ConsumerWidget {
  const ManageOrgUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curOrgId = ref.watch(curOrgDependencyProvider);

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
                title: Text(joinedRole.user?.email ??
                    AppLocalizations.of(context)!.noEmailFound),
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
