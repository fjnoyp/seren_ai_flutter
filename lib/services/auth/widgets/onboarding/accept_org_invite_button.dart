import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/users/models/invite_model.dart';
import 'package:seren_ai_flutter/services/data/users/providers/cur_user_invites_notifier_provider.dart';

class AcceptInviteButton extends ConsumerWidget {
  const AcceptInviteButton(this.invite, {super.key});

  final InviteModel invite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton(
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
      child: Text(AppLocalizations.of(context)!.goTo(invite.orgName)),
    );
  }
}
