import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_joined_org_roles_stream_provider.dart';

class ChooseOrgPage extends ConsumerWidget {
  const ChooseOrgPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curOrgId = ref.watch(curSelectedOrgIdNotifierProvider);

    final theme = Theme.of(context);

    return AsyncValueHandlerWidget(
      value: ref.watch(curUserJoinedOrgRolesStreamProvider),
      data: (orgRoles) => orgRoles.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.noOrganizations))
          : ListView.builder(
              itemCount: orgRoles.length,
              itemBuilder: (context, index) {
                final joinedOrgRole = orgRoles[index];

                final orgModel = joinedOrgRole.org;
                final orgRoleModel = joinedOrgRole.orgRole;

                if (orgModel == null) {
                  return Text(AppLocalizations.of(context)!.errorCannotLoadOrg);
                }

                final isSelected = curOrgId == orgModel.id;

                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Center(child: Text(orgModel.name)),
                    subtitle: Center(
                      child:
                          Text(orgRoleModel.orgRole.toHumanReadable(context)),
                    ),
                    onTap: () {
                      ref
                          .read(curSelectedOrgIdNotifierProvider.notifier)
                          .setDesiredOrgId(orgModel.id);
                    },
                  ),
                );
              },
            ),
    );
  }
}
