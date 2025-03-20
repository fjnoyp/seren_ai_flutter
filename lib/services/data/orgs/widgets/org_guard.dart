import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_orgs_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/orgs_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Ensure user has a current organization or redirect to chooseOrgRoute page
class OrgGuard extends ConsumerWidget {
  final Widget child;

  const OrgGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curOrgId = ref.watch(curSelectedOrgIdNotifierProvider);
    final curUserOrgs = ref.watch(curUserOrgsProvider);

    // Check if user no longer belongs to current org
    if (curUserOrgs.hasValue &&
        _userNoLongerBelongsTo(curOrgId, curUserOrgs: curUserOrgs.value!)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                    ?.youAreNotAMemberOfThisOrg ??
                'You\'re trying to access an organization you are not a member of.'),
          ),
        );
      });
      ref.read(curSelectedOrgIdNotifierProvider.notifier).clearDesiredOrgId();
    }

    if (curOrgId == null) {
      if (curUserOrgs.hasValue) {
        if (curUserOrgs.value!.length == 1) {
          // If user only has one org, set it as the desired org
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(curSelectedOrgIdNotifierProvider.notifier)
                .setDesiredOrgId(curUserOrgs.value!.first.id);
          });
          return const Center(child: CircularProgressIndicator());
        } else if (curUserOrgs.value!.length > 1) {
          // If user has multiple orgs, navigate to chooseOrg page
          WidgetsBinding.instance.addPostFrameCallback((_) => ref
              .read(navigationServiceProvider)
              .navigateTo(AppRoutes.chooseOrg.name));
          return const Center(child: CircularProgressIndicator());
        }
      }

      // Handle empty orgs case with retry logic
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _retryLoadingOrgs(context, ref);
      });

      return const Center(child: CircularProgressIndicator());
    }

    // (curOrgId != null) - just show the page
    return child;
  }

  Future<void> _retryLoadingOrgs(BuildContext context, WidgetRef ref) async {
    // Get the repository directly for more reliable async calls
    final userId = ref.watch(curUserProvider).value?.id ?? '';

    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(seconds: 2));
      if (!context.mounted) return;

      try {
        // Direct repository call instead of watching the stream
        final orgs =
            await ref.read(orgsRepositoryProvider).getUserOrgs(userId: userId);

        if (orgs.isNotEmpty && context.mounted) {
          // Update the provider with the loaded orgs
          ref.invalidate(curUserOrgsProvider);
          break;
        }
      } catch (e) {
        // Log error but continue retrying
        debugPrint('OrgGuard: Error fetching orgs in attempt ${i + 1}: $e');
      }
    }

    final hasOrgs =
        (await ref.read(orgsRepositoryProvider).getUserOrgs(userId: userId))
            .isNotEmpty;

    // If we still don't have orgs, show dialog
    if (context.mounted && !hasOrgs) {
      final shouldRedirect = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                    AppLocalizations.of(context)?.connectionIssueTitle ??
                        'Connection Issue'),
                content: Text(AppLocalizations.of(context)
                        ?.connectionIssueMessage ??
                    'We\'re having trouble loading your organizations. Do you want to create a new organization or keep trying?'),
                actions: <Widget>[
                  TextButton(
                    child: Text(AppLocalizations.of(context)?.keepTrying ??
                        'Keep Trying'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text(
                        AppLocalizations.of(context)?.createNewOrganization ??
                            'Create New Organization'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          ) ??
          false;

      if (shouldRedirect && context.mounted) {
        ref
            .read(navigationServiceProvider)
            .navigateTo(AppRoutes.onboarding.name, clearStack: true);
      } else if (context.mounted) {
        // User chose to keep trying, restart the retry process
        // Call the retry method again instead of just invalidating the provider
        _retryLoadingOrgs(context, ref);
      } else {
        debugPrint('OrgGuard: Error: Context is not mounted');
      }
    }
  }

  bool _userNoLongerBelongsTo(String? curOrgId,
          {required List<OrgModel> curUserOrgs}) =>
      curOrgId != null && !(curUserOrgs.any((org) => org.id == curOrgId));
}
