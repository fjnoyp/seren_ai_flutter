import 'package:seren_ai_flutter/services/data/users/models/invite_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

class JoinedInviteModel {
  final InviteModel invite;
  final OrgModel org;
  final UserModel authorUser;

  JoinedInviteModel({
    required this.invite,
    required this.org,
    required this.authorUser,
  });

  factory JoinedInviteModel.fromJson(Map<String, dynamic> json) {
    return JoinedInviteModel(
      invite: InviteModel.fromJson(json['invite']),
      org: OrgModel.fromJson(json['org']),
      authorUser: UserModel.fromJson(json['author_user']),
    );
  }
}
