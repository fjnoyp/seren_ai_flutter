import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_orgs_provider.dart';

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
        for (int i = 0; i < 3; i++) {
          await Future.delayed(const Duration(seconds: 2));
          if (!context.mounted) return;
          final orgs = await ref.refresh(curUserOrgsProvider.future);
          if (orgs.isNotEmpty) {
            return;
          }
        }
        // If still no orgs after retries, navigate to onboarding page
        if (context.mounted) {
          ref
              .read(navigationServiceProvider)
              .navigateTo(AppRoutes.onboarding.name);
        }
      });

      return const Center(child: CircularProgressIndicator());
    }

    return child;
  }

  bool _userNoLongerBelongsTo(String? curOrgId,
          {required List<OrgModel> curUserOrgs}) =>
      !(curUserOrgs.any((org) => org.id == curOrgId));
}
