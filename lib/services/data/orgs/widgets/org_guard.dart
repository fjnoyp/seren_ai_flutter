import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_org_id_provider.dart';

/// Ensure user has a current organization or redirect to chooseOrgRoute page
class OrgGuard extends ConsumerWidget {
  final Widget child;

  const OrgGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final curOrgId = ref.watch(curOrgIdProvider);

    if (curOrgId == null) {
      // Redirect to choose organization page if no current organization is selected
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, chooseOrgRoute, (route) => false);
      });
      return Container(); // Return an empty container while redirecting
    }    

    return child;
  }
}
