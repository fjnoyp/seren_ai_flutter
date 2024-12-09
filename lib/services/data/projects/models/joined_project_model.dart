import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

class JoinedProjectModel {
  final ProjectModel project;
  final OrgModel org;
  final List<UserModel> assignees;

  JoinedProjectModel({
    required this.project,
    required this.org,
    required this.assignees,
  });

  factory JoinedProjectModel.empty() {
    return JoinedProjectModel(
      project: ProjectModel.empty(),
      org: OrgModel(name: ''),
      assignees: [],
    );
  }

  JoinedProjectModel copyWith({
    ProjectModel? project,
    List<UserModel>? assignees,
  }) {
    return JoinedProjectModel(
      project: project ?? this.project,
      org: org,
      assignees: assignees ?? this.assignees,
    );
  }

  factory JoinedProjectModel.fromJson(Map<String, dynamic> json) {
    final project = ProjectModel.fromJson(json['project']);
    final org = OrgModel.fromJson(json['org']);
    final assignees = <UserModel>[
      ...json['assignees']
          .where((e) => e != null)
          .map((e) => UserModel.fromJson(e))
    ];

    return JoinedProjectModel(
      project: project,
      org: org,
      assignees: assignees,
    );
  }

  bool get isValidProject =>
      project.name.isNotEmpty && project.parentOrgId.isNotEmpty;

  Map<String, dynamic> toReadableMap() {
    return {
      'project': {
        'name': project.name,
        'description': project.description,
        'address': project.address,
      },
      'org': {
        'name': org.name,
        'address': org.address,
      },
      'assignees': assignees.map((user) => user.email).toList(),
    };
  }
}
