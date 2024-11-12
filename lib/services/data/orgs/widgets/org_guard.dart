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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoute.chooseOrg.name, (route) => false);
      });
      return Container();
    }

    return child;
  }

  bool _userNoLongerBelongsTo(String? curOrgId,
          {required List<OrgModel> curUserOrgs}) =>
      !(curUserOrgs.any((org) => org.id == curOrgId));
}
