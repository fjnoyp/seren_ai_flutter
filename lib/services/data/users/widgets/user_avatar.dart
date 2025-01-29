import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserAvatar extends StatefulWidget {
  const UserAvatar(this.user, {super.key, this.radius});

  final UserModel user;
  final double? radius;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  bool _isHovering = false;
  final _overlayKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        children: [
          CircleAvatar(
            key: _overlayKey,
            radius: widget.radius,
            child: ClipOval(
              child: Image.network(
                _getUserImage(),
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      '${widget.user.firstName.substring(0, 1)}${(widget.radius ?? 16) > 12 ? widget.user.lastName.substring(0, 1) : ''}',
                    ),
                  );
                },
              ),
            ),
          ),
          if (_isHovering)
            Positioned(
              top: -(widget.radius ?? 16) - 24,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${widget.user.firstName} ${widget.user.lastName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getUserImage() {
    return Supabase.instance.client.storage
        .from('user_avatars')
        .getPublicUrl(widget.user.id);
  }
}
