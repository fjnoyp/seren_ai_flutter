import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_role_provider.dart';

/// Helper to create providers that depend on authenticated user
class IsCurUserOrgAdminDependencyProvider {
  static AsyncValue<T> get<T>({
    required Ref ref,
    required AsyncValue<T> Function(bool isAdmin) builder,
  }) {
    final isOrgAdmin = ref.watch(curUserOrgRoleProvider);

    return isOrgAdmin.when(
      data: (role) => builder(role == OrgRole.admin),
      error: (error, _) => AsyncValue.error(error, StackTrace.empty),
      loading: () => const AsyncValue.loading(),
    );
  }

  static Stream<T> watchStream<T>({
    required Ref ref,
    required Stream<T> Function(bool isAdmin) builder,
  }) {
    final isOrgAdmin = ref.watch(curUserOrgRoleProvider);

    return isOrgAdmin.when(
      data: (role) => builder(role == OrgRole.admin),
      error: (error, _) => Stream.error(error),
      loading: () => const Stream.empty(),
    );
  }
}
