// constants for all routes

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';

const String signInUpRoute = '/signInUp';
const String chooseOrgRoute = '/chooseOrg';
//const String chooseTeamRoute = '/chooseTeam';
const String projectsRoute = '/projects'; 
const String manageOrgUsersRoute = '/manageOrgUsers';
const String manageTeamUsersRoute = '/manageTeamUsers';
//const String manageTasksRoute = '/manageTasks';
const String homeRoute = '/home';
const String testRoute = '/test';
const String tasksRoute = '/tasks'; 
//const String createTaskRoute = '/createTask';
//const String viewTaskRoute = '/viewTask'; 
const String taskPageRoute = '/taskPage';

const String testSQLPageRoute = '/testSQLPage';

final simpleDateFormat = DateFormat('MMM dd, yyyy HH:mm');



void openTaskPage(BuildContext context, {required TaskPageMode mode, JoinedTaskModel? joinedTask}) {
  Navigator.pushNamed(context, taskPageRoute, arguments: {'mode': mode, 'joinedTask': joinedTask});
}