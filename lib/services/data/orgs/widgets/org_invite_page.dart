import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/users/providers/cur_user_invites_notifier_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrgInvitePage extends ConsumerWidget {
  final String orgId;

  const OrgInvitePage({super.key, required this.orgId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invite = ref
        .watch(curUserInvitesNotifierProvider)
        .firstWhere((invite) => invite.orgId == orgId);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.pendingInvite,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.pendingInviteBody(
                    invite.authorUserName,
                    invite.orgName,
                    invite.orgRole.toHumanReadable(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        ref
                            .read(curUserInvitesNotifierProvider.notifier)
                            .declineInvite(invite);
                        ref.read(navigationServiceProvider).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: Text(AppLocalizations.of(context)!.decline),
                    ),
                    FilledButton(
                      onPressed: () async {
                        await ref
                            .read(curUserInvitesNotifierProvider.notifier)
                            .acceptInvite(invite);
                        ref
                            .read(curSelectedOrgIdNotifierProvider.notifier)
                            .setDesiredOrgId(invite.orgId);
                        ref.read(navigationServiceProvider).navigateTo(
                              AppRoutes.home.name,
                              clearStack: true,
                            );
                      },
                      child: Text(AppLocalizations.of(context)!.accept),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
