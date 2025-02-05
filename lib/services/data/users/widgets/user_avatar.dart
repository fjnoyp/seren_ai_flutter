import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar(this.user, {super.key, this.radius});

  final UserModel user;
  final double? radius;

  // Cache for existence checks
  static final Map<String, bool> _imageExistsCache = {};

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${user.firstName} ${user.lastName}',
      child: CircleAvatar(
        radius: radius,
        child: ClipOval(
          child: FutureBuilder<bool>(
            future: _checkImageExists(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return Image.network(
                  _getUserImage(),
                  gaplessPlayback: true,
                  errorBuilder: (context, _, __) {
                    _imageExistsCache.remove(user.id);
                    return _FallbackAvatar(user: user, radius: radius);
                  },
                );
              }
              return _FallbackAvatar(user: user, radius: radius);
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _checkImageExists() async {
    // Check cache first
    if (_imageExistsCache.containsKey(user.id)) {
      return _imageExistsCache[user.id]!;
    }

    try {
      await Supabase.instance.client.storage
          .from('user_avatars')
          .createSignedUrl(user.id, 30);
      _imageExistsCache[user.id] = true;
      return true;
    } catch (e) {
      _imageExistsCache[user.id] = false;
      return false;
    }
  }

  String _getUserImage() {
    return Supabase.instance.client.storage
        .from('user_avatars')
        .getPublicUrl(user.id);
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.user, this.radius});

  final UserModel user;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '${user.firstName.substring(0, 1)}${(radius ?? 16) > 12 ? user.lastName.substring(0, 1) : ''}',
      ),
    );
  }
}
