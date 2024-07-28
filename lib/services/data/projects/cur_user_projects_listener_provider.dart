import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/is_cur_user_org_admin_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';

// Provide all projects for current user
final curUserProjectsListenerProvider = NotifierProvider<CurUserProjectsListenerNotifier, List<ProjectModel>?>(
  CurUserProjectsListenerNotifier.new
);

/// Get the current user's projects
class CurUserProjectsListenerNotifier extends Notifier<List<ProjectModel>?> {

  @override
  List<ProjectModel>? build() {

    final watchedCurAuthUser = ref.watch(curAuthUserProvider);

    if(watchedCurAuthUser == null) {
      return null;
    }

    final db = ref.read(dbProvider);

    // Get all projects which user is assigned to 
    // TODO: org admins should be able to see all projects 
    final query = '''
    SELECT p.*
    FROM projects p
    JOIN user_project_roles upr on p.id = upr.project_id
    WHERE upr.user_id = '${watchedCurAuthUser.id}'; 
    ''';     

    final subscription = db.watch(query).listen((results) {
      List<ProjectModel> items = results.map((e) => ProjectModel.fromJson(e)).toList();
      state = items; 
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null; 
  }  
}

/*
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    parent_org_id UUID NOT NULL,  -- Foreign key to org
    parent_team_id UUID, -- Foreign key to team 
    FOREIGN KEY (parent_org_id) REFERENCES orgs(id),
    FOREIGN KEY (parent_team_id) REFERENCES teams(id)
);

-- USER_PROJECT_ROLES
CREATE TABLE user_project_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(), 
    user_id UUID NOT NULL, -- Foreign key to user 
    project_id UUID NOT NULL,  -- Foreign key to project
    project_role VARCHAR(50) NOT NULL CHECK (project_role IN ('admin', 'editor', 'member')),     
    FOREIGN KEY (project_id) REFERENCES projects(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
*/