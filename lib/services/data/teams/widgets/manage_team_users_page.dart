import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_org_id_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_cacher_database_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/user_team_roles/joined_user_team_roles_listener_fam_provider.dart';

final _currentTeamIdProvider = StateProvider<String?>((ref) => null);

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

    return FutureBuilder<List<TeamModel>>(
      future: ref.read(teamsCacherDatabaseProvider).getItems(eqFilters: [{'key': 'parent_org_id', 'value': curOrgId}]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final teams = snapshot.data ?? [];
        
        List<DropdownMenuItem<String>> teamItems = teams.map((team) {
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
            ref.read(_currentTeamIdProvider.notifier).state = newValue;
          },
          items: teamItems,
        );
      },
    );
  }
}

class TeamUsersList extends ConsumerWidget {
  const TeamUsersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTeamId = ref.watch(_currentTeamIdProvider);

    if (curTeamId == null) {
      return const Center(child: Text('Error - No team selected.'));
    }

    final joinedTeamRoles = ref.watch(joinedUserTeamRolesListenerFamProvider(curTeamId));

    return joinedTeamRoles == null || joinedTeamRoles.isEmpty
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
