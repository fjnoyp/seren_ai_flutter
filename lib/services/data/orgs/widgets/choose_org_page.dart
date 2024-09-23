import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_org_id_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/joined_cur_user_org_roles_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/user_org_roles/joined_user_org_roles_listener_fam_provider.dart';

class ChooseOrgPage extends ConsumerWidget {
  const ChooseOrgPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgRoles = ref.watch(joinedCurUserOrgRolesListenerProvider);
    final curOrgId = ref.watch(curOrgIdProvider);

    if(orgRoles == null) {
      return const Center(
        child: 
            Text('Waiting for orgRoles to load...'),
      );      
    }

    final theme = Theme.of(context);

    return orgRoles.isEmpty
          ? const Center(child: Text('No organizations available'))
          : ListView.builder(
              itemCount: orgRoles.length,
              itemBuilder: (context, index) {
                final orgRole = orgRoles[index];

                final orgModel = orgRole.org; 
                final orgRoleModel = orgRole.orgRole;

                if(orgModel == null) {
                  return const Text('Error cannot load organization');
                }


                final isSelected = curOrgId == orgModel.id;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                    color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Center(child: Text(orgModel.name)),
                    subtitle: Center(child: Text(orgRoleModel.orgRole)),
                    onTap: () {
                      ref.read(curOrgIdProvider.notifier).setDesiredOrgId(orgModel.id);
                    },
                  ),
                );
              },
      );
  }
}
