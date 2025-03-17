import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/org_stream_provider.dart';

class DeleteOrgButton extends ConsumerWidget {
  const DeleteOrgButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgId = ref.watch(curSelectedOrgIdNotifierProvider);
    if (orgId == null) return const SizedBox.shrink();

    return IconButton(
      tooltip: AppLocalizations.of(context)!.deleteOrgTooltip,
      icon: const Icon(Icons.delete),
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return AsyncValueHandlerWidget(
              value: ref.watch(orgStreamProvider(orgId)),
              data: (org) => org != null
                  ? DeleteConfirmationDialog(
                      itemName: org.name,
                      onDelete: () async {
                        try {
                          // Capture the scaffold context before any navigation
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);
                          final orgName = org.name;

                          // Use a single call to handle both operations atomically
                          await ref
                              .read(curSelectedOrgIdNotifierProvider.notifier)
                              .disableOrgAndRemoveAllRoles();

                          // Show a snackbar to confirm the deletion before navigation
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                                content: Text('$orgName has been deleted.')),
                          );

                          // Reset the navigation stack to the home page (it'll be redirected accordingly);
                          ref.read(navigationServiceProvider).navigateTo(
                                AppRoutes.home.name,
                                clearStack: true,
                              );
                        } catch (e) {
                          // Show error message with valid context
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Failed to delete ${org.name}. Please try again later.'),
                              ),
                            );
                          }
                        }
                      },
                    )
                  : const Center(child: Text('Error: could not find org')),
            );
          },
        );
      },
    );
  }
}
