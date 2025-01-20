import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrgAvatarImage extends StatelessWidget {
  const OrgAvatarImage({super.key, required this.org});

  final OrgModel org;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _getOrgImage(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(child: Text(org.name.substring(0, 1)));
          },
        ),
      ),
    );
  }

  String _getOrgImage() {
    return Supabase.instance.client.storage
        .from('org_avatars')
        .getPublicUrl(org.id);
  }
}
