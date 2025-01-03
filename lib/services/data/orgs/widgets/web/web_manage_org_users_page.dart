import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_roles_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/action_buttons/invite_user_to_org_button.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/manage_org_users_page.dart';

class WebManageOrgUsersPage extends HookConsumerWidget {
  const WebManageOrgUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curOrgId = ref.watch(curOrgIdProvider);

    if (curOrgId == null) {
      return Center(child: Text(AppLocalizations.of(context)!.noOrgSelected));
    }

    final searchText = useTextEditingController();
    useListenable(searchText);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => ref.read(navigationServiceProvider).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              Text(AppLocalizations.of(context)!.users,
                  style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: searchText,
                decoration: const InputDecoration(
                  isDense: true,
                  fillColor: Colors.transparent,
                  suffixIcon: Icon(Icons.search),
                ),
              )),
              const SizedBox(width: 10),
              if (ref.read(curUserOrgRoleProvider).value == OrgRole.admin)
                FilledButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const InviteUserByEmailDialog(),
                  ),
                  icon: const Icon(Icons.person_add),
                  label: Text(AppLocalizations.of(context)!.inviteUser),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
              child: _UsersTable(
                  filter: (joinedOrgRole) =>
                      joinedOrgRole.user!.email
                          .toLowerCase()
                          .contains(searchText.text.toLowerCase()) ||
                      '${joinedOrgRole.user!.firstName} ${joinedOrgRole.user!.lastName}'
                          .toLowerCase()
                          .contains(searchText.text.toLowerCase()) ||
                      joinedOrgRole.orgRole.orgRole
                          .toHumanReadable(context)
                          .toLowerCase()
                          .contains(searchText.text.toLowerCase()))),
        ],
      ),
    );
  }
}

class _UsersTable extends ConsumerWidget {
  const _UsersTable({this.filter});

  final bool Function(JoinedUserOrgRoleModel joinedOrgRole)? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinedOrgRoles = ref.watch(joinedCurOrgRolesProvider);

    final filteredJoinedOrgRoles = joinedOrgRoles.valueOrNull
            ?.where((joinedOrgRole) => filter?.call(joinedOrgRole) ?? true)
            .toList() ??
        [];

    return filteredJoinedOrgRoles.isEmpty
        ? Center(child: Text(AppLocalizations.of(context)!.noUsersInOrg))
        : Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(AppLocalizations.of(context)!.name),
                        ),
                        Expanded(
                          child: Text(AppLocalizations.of(context)!.email),
                        ),
                        Expanded(
                          child: Text(AppLocalizations.of(context)!.role),
                        ),
                        Expanded(
                          child:
                              Text(AppLocalizations.of(context)!.creationDate),
                        ),
                        Expanded(
                          child:
                              Text(AppLocalizations.of(context)!.lastUpdated),
                        )
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredJoinedOrgRoles.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final user = filteredJoinedOrgRoles[index].user!;
                        final role = filteredJoinedOrgRoles[index].orgRole;

                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${user.firstName} ${user.lastName}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                user.email,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text(role.orgRole.toHumanReadable(context)),
                                  IconButton(
                                    iconSize: 12,
                                    icon: const Icon(Icons.edit),
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    hoverColor: Colors.transparent,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            ChangeUserRoleDialog(
                                                currentUserRole:
                                                    filteredJoinedOrgRoles[
                                                        index]),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                DateFormat.yMd(AppLocalizations.of(context)!
                                        .localeName)
                                    .add_Hm()
                                    .format(user.createdAt!.toLocal()),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                DateFormat.yMd(AppLocalizations.of(context)!
                                        .localeName)
                                    .add_Hm()
                                    .format(user.updatedAt!.toLocal()),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
