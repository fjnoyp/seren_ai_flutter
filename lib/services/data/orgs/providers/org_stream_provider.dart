import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/orgs_repository.dart';

final orgStreamProvider =
    StreamProvider.family<OrgModel?, String>((ref, orgId) {
  final orgsRepo = ref.read(orgsRepositoryProvider);
  return orgsRepo.watchById(orgId);
});
