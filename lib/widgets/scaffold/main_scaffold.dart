import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_modal_visible_provider.dart';
import 'package:seren_ai_flutter/services/ai/widgets/base_ai_assistant_button.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button.dart';
import 'package:seren_ai_flutter/services/ai/widgets/user_input_display_widget.dart';
import 'package:seren_ai_flutter/services/ai/widgets/web_ai_assistant_modal.dart';
import 'package:seren_ai_flutter/services/data/db_setup/app_config.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/users/models/invite_model.dart';
import 'package:seren_ai_flutter/services/data/users/providers/cur_user_invites_service_provider.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_mode_provider.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_state_modal.dart';
import 'package:seren_ai_flutter/widgets/scaffold/bottom_app_bar_base.dart';
import 'package:seren_ai_flutter/widgets/scaffold/mobile_scaffold.dart';
import 'package:seren_ai_flutter/widgets/scaffold/web_scaffold.dart';
import 'drawer_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final FloatingActionButton? floatingActionButton;
  final bool showAiAssistant;
  final List<Widget>? actions;

  // This is a temporary solution to hide the app bar on the project page.
  // The future goal is not to show the app bar on any web pages at all,
  // but this is a quick fix to make the project page look better for now.
  // TODO p2: remove this once we adjust the web layout on all pages
  final bool showAppBar;

  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.showAiAssistant = true,
    this.actions,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAiAssistantExpanded = ref.watch(isAiModalVisibleProvider);
    final curUserPendingInvites = ref.watch(curUserInvitesServiceProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final invite in curUserPendingInvites) {
        _showInviteDialog(context, ref, invite);
      }
    });

    return PopScope(
      canPop: ref.read(navigationServiceProvider).canPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.home.name, (route) => false);
        }
      },
      child: isWebVersion
          ? WebScaffold(
              title: title,
              body: body,
              showAiAssistant: showAiAssistant,
              actions: actions,
              showAppBar: showAppBar,
              isAiAssistantExpanded: isAiAssistantExpanded,
            )
          : MobileScaffold(
              title: title,
              body: body,
              showAiAssistant: showAiAssistant,
              actions: actions,
              isAiAssistantExpanded: isAiAssistantExpanded,
            ),
    );
  }

  Future<dynamic> _showInviteDialog(
      BuildContext context, WidgetRef ref, InviteModel invite) {
    final curUserInvitesService =
        ref.read(curUserInvitesServiceProvider.notifier);
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.pendingInvite),
        content: Text(AppLocalizations.of(context)!.pendingInviteBody(
            invite.authorUserName,
            invite.orgName,
            invite.orgRole.toHumanReadable(context))),
        actions: [
          TextButton(
            onPressed: () {
              curUserInvitesService.declineInvite(invite);
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.decline),
          ),
          FilledButton(
            onPressed: () {
              curUserInvitesService.acceptInvite(invite);
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.accept),
          ),
        ],
      ),
    );
  }
}
