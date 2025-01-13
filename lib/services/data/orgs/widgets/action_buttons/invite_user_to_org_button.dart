import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/org_invite_service_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InviteUserToOrgButton extends ConsumerWidget {
  const InviteUserToOrgButton({required this.orgId, super.key});

  final String orgId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.person_add),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => InviteUserByEmailDialog(orgId: orgId),
        );
      },
    );
  }
}

class InviteUserByEmailDialog extends HookConsumerWidget {
  const InviteUserByEmailDialog({required this.orgId, super.key});

  final String orgId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final orgRole = useState(OrgRole.member);

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.inviteUserToOrg),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.inviteAs),
              DropdownButton<OrgRole>(
                value: orgRole.value,
                onChanged: (OrgRole? newOrgRole) {
                  if (newOrgRole != null) {
                    orgRole.value = newOrgRole;
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: OrgRole.member,
                    child: Text(OrgRole.member.toHumanReadable(context)),
                  ),
                  DropdownMenuItem(
                    value: OrgRole.editor,
                    child: Text(OrgRole.editor.toHumanReadable(context)),
                  ),
                  DropdownMenuItem(
                    value: OrgRole.admin,
                    child: Text(OrgRole.admin.toHumanReadable(context)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => ref
              .read(orgInviteServiceProvider)
              .inviteUser(orgId, emailController.text, orgRole.value)
              .then((_) => Navigator.pop(context)),
          child: Text(AppLocalizations.of(context)!.invite),
        ),
      ],
    );
  }
}
