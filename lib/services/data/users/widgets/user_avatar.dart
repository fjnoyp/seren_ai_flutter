import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar(this.user, {super.key, this.radius});

  final UserModel user;
  final double? radius;

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
                  errorBuilder: (context, error, stackTrace) =>
                      _FallbackAvatar(user: user, radius: radius),
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
    try {
      await Supabase.instance.client.storage
          .from('user_avatars')
          .createSignedUrl(user.id, 10); // 10 seconds expiry
      return true;
    } catch (e) {
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
