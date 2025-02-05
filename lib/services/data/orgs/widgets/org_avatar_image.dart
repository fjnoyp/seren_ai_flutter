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
        child: FutureBuilder<bool>(
          future: _checkImageExists(),
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return Image.network(
                _getOrgImage(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _FallbackAvatar(org: org);
                },
              );
            }
            return _FallbackAvatar(org: org);
          },
        ),
      ),
    );
  }

  Future<bool> _checkImageExists() async {
    try {
      await Supabase.instance.client.storage
          .from('org_avatars')
          .createSignedUrl(org.id, 10); // 10 seconds expiry
      return true;
    } catch (e) {
      return false;
    }
  }

  String _getOrgImage() {
    return Supabase.instance.client.storage
        .from('org_avatars')
        .getPublicUrl(org.id);
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.org});

  final OrgModel org;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(org.name.substring(0, 1)));
  }
}
