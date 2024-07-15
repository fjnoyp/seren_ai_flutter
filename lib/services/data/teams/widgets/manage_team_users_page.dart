import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_org_id_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/is_cur_org_admin_comp_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_team_id_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_user_team_roles_list_listener_database_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_listener_database_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/user_team_roles/joined_user_team_roles_cacher_comp_provider.dart';

class ManageTeamUsersPage extends ConsumerWidget {
  const ManageTeamUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curOrgId = ref.watch(curOrgIdProvider);

    if (curOrgId == null) {
      return const Center(child: Text('Error - No org selected. Wrap with OrgGuard'));
    }

    return const Column(
      children: [
        CurTeamSelectionDropdown(),
        Expanded(child: TeamUsersList()),
      ],
    );
  }
}

class CurTeamSelectionDropdown extends HookConsumerWidget {
  const CurTeamSelectionDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curOrgId = ref.watch(curOrgIdProvider);
    final selectedTeamId = useState<String?>(null);
    final selectedTeamName = useState<String?>(null);

    if (curOrgId == null) {
      return const Center(child: Text('Error - No org selected. Wrap with OrgGuard'));
    }

    // TODO: create as separate provider 

    final teams = ref.watch(teamsListenerDatabaseProvider(curOrgId));

    final curUserTeamRoles = ref.watch(curUserTeamRolesListListenerDatabaseProvider);

    final isCurOrgAdmin = ref.watch(isCurOrgAdminCompListenerProvider);

    final selectableTeams = isCurOrgAdmin ? teams : teams.where((team) => curUserTeamRoles?.any((role) => role.teamId == team.id) ?? false).toList();

    List<DropdownMenuItem<String>> teamItems = selectableTeams.map((team) {
      return DropdownMenuItem<String>(
        value: team.id,
        child: Text(team.name),
      );
    }).toList();

    return DropdownButton<String>(
      hint: const Text('Select a team'),
      value: selectedTeamId.value,
      onChanged: (String? newValue) {
        selectedTeamId.value = newValue;
        selectedTeamName.value = teams.firstWhere((team) => team.id == newValue).name;        
        ref.read(curTeamIdProvider.notifier).setTeamId(selectedTeamId.value);
      },
      items: teamItems,
    );
  }
}

class TeamUsersList extends ConsumerWidget {
  const TeamUsersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTeamId = ref.watch(curTeamIdProvider);

    if (curTeamId == null) {
      return const Center(child: Text('Error - No team selected.'));
    }

    final joinedTeamRoles = ref.watch(joinedUserTeamRolesCacherCompProvider(curTeamId));

    return joinedTeamRoles.isEmpty
          ? const Center(child: Text('No users found in this team.'))
          : ListView.builder(
              itemCount: joinedTeamRoles.length,
              itemBuilder: (context, index) {
                final joinedRole = joinedTeamRoles[index];
                return ListTile(
                  title: Text(joinedRole.user.email ?? 'No email'),
                  subtitle: Text(joinedRole.teamRole.teamRole),
                );
              },
            );
  }
}
