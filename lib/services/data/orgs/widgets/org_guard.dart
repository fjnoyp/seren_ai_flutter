import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_service_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_orgs_provider.dart';

/// Ensure user has a current organization or redirect to chooseOrgRoute page
class OrgGuard extends ConsumerWidget {
  final Widget child;

  const OrgGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curOrgId = ref.watch(curOrgIdProvider);

    final curUserOrgs = ref.watch(curUserOrgsProvider);
    if (curUserOrgs.hasValue &&
        _userNoLongerBelongsTo(curOrgId, curUserOrgs: curUserOrgs.value!)) {
      ref.read(curUserOrgServiceProvider).clearDesiredOrgId();
    }

    if (curOrgId == null) {
      if (curUserOrgs.hasValue) {
        if (curUserOrgs.value!.length == 1) {
          // If user only has one org, set it as the desired org
          ref
              .read(curUserOrgServiceProvider)
              .setDesiredOrgId(curUserOrgs.value!.first.id);
        } else {
          // We need to add retry logic if orgs list is empty because
          // the orgs list isn't always being updated in time
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            for (int i = 0; i < 3; i++) {
              await Future.delayed(const Duration(milliseconds: 500));
              if (!context.mounted) return; // Check if widget is still mounted
              final orgs = await ref.refresh(curUserOrgsProvider.future);
              if (orgs.isNotEmpty) {
                return; // Exit if we got orgs
              }
            }
            // If still no orgs after retries, proceed with navigation
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.chooseOrg.name, (route) => false);
          });
        }
      }

      return const Center(child: CircularProgressIndicator());
    }

    return child;
  }

  bool _userNoLongerBelongsTo(String? curOrgId,
          {required List<OrgModel> curUserOrgs}) =>
      !(curUserOrgs.any((org) => org.id == curOrgId));
}
