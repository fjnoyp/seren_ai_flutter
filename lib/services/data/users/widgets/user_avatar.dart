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
          child: Image.network(
            _getUserImage(),
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  '${user.firstName.substring(0, 1)}${(radius ?? 16) > 12 ? user.lastName.substring(0, 1) : ''}',
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getUserImage() {
    return Supabase.instance.client.storage
        .from('user_avatars')
        .getPublicUrl(user.id);
  }
}
