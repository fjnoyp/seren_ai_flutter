import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_org_id_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/joined_cur_user_org_roles_comp_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/user_org_roles/joined_user_org_roles_comp_provider.dart';

class ManageOrgUsersPage extends ConsumerWidget {
  const ManageOrgUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curOrgId = ref.watch(curOrgIdProvider);

    if(curOrgId == null){
      return const Center(child: Text('Error - No organization selected.'));
    }

    final joinedOrgRoles = ref.watch(joinedUserOrgRolesCompProvider(curOrgId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Organization Users'),
      ),
      body: joinedOrgRoles.isEmpty
          ? const Center(child: Text('No users found in this organization.'))
          : ListView.builder(
              itemCount: joinedOrgRoles.length,
              itemBuilder: (context, index) {
                final joinedRole = joinedOrgRoles[index];
                return ListTile(
                  title: Text(joinedRole.authUser.email ?? 'No email'),
                  subtitle: Text(joinedRole.orgRole.orgRole),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Implement user removal logic here
                    },
                  ),
                );
              },
            ),
    );
  }
}
