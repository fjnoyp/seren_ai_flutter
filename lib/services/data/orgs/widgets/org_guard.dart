import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
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
    final currentRoute = ref.read(currentRouteProvider);

    // Check if user no longer belongs to current org
    if (curUserOrgs.hasValue &&
        _userNoLongerBelongsTo(curOrgId, curUserOrgs: curUserOrgs.value!) &&
        currentRoute != AppRoutes.onboarding.name &&
        currentRoute != AppRoutes.noInvites.name) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
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

      if (currentRoute == AppRoutes.onboarding.name) {
        return child;
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
        // unless the current user is already being onboarded
        if (context.mounted && currentRoute != AppRoutes.onboarding.name) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text(
          //         'Slow connection. If you already have an organization, please wait a moment and you\'ll be redirected automatically.'),
          //     duration: Duration(seconds: 6),
          //   ),
          // );
          ref
              .read(navigationServiceProvider)
              .navigateTo(AppRoutes.onboarding.name, clearStack: true);
        }
      });

      return const Center(child: CircularProgressIndicator());
    }

    // (curOrgId != null) cases:
    // 1. user is onboarding - navigate to home (will be redirected accordingly)
    if (currentRoute == AppRoutes.onboarding.name) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(navigationServiceProvider)
            .navigateTo(AppRoutes.home.name, clearStack: true);
      });
      return const Center(child: CircularProgressIndicator());
    } else {
      // 2. user is not onboarding - show the page
      return child;
    }
  }

  bool _userNoLongerBelongsTo(String? curOrgId,
          {required List<OrgModel> curUserOrgs}) =>
      curOrgId != null && !(curUserOrgs.any((org) => org.id == curOrgId));
}
