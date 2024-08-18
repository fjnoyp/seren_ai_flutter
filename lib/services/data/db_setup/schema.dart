import 'package:powersync/powersync.dart';


const usersTable = 'users';
const orgsTable = 'orgs';
const teamsTable = 'teams';
const projectsTable = 'projects';
const userOrgRolesTable = 'user_org_roles';
const userTeamRolesTable = 'user_team_roles';
const userProjectRolesTable = 'user_project_roles';

// TODO p5: generate from model classes ...
// Generate Schema classes that create the Table schemas 
// And provide field getters for constructing queries 

const permissionSchemas = [
  Table(usersTable, [
    Column.text('id'),
    Column.text('parent_auth_user_id'),
    Column.text('email'),
  ]),
  Table(orgsTable, [
    Column.text('id'),
    Column.text('name'),
    Column.text('address'),
  ]),
  Table(teamsTable, [
    Column.text('id'),
    Column.text('name'),
    Column.text('parent_org_id'),
  ]),
  Table(projectsTable, [
    Column.text('id'),
    Column.text('name'),
    Column.text('description'),
    Column.text('parent_org_id'),
    Column.text('parent_team_id'),
  ]),
  Table(userOrgRolesTable, [
    Column.text('id'),
    Column.text('user_id'),
    Column.text('org_id'),
    Column.text('org_role'),
  ]),
  Table(userTeamRolesTable, [
    Column.text('id'),
    Column.text('user_id'),
    Column.text('team_id'),
    Column.text('team_role'),
  ]),
  Table(userProjectRolesTable, [
    Column.text('id'),
    Column.text('user_id'),
    Column.text('project_id'),
    Column.text('project_role'),
  ]),
];

const tasksTable = 'tasks';
const taskCommentsTable = 'task_comments';
const taskUserAssignmentsTable = 'task_user_assignments';

const tasksSchemas = [
  Table(tasksTable, [
    Column.text('id'),
    Column.text('name'),
    Column.text('description'),
    Column.text('status_enum'),
    Column.text('priority_enum'),
    Column.text('due_date'),
    Column.text('created_date'),
    Column.text('last_updated_date'),
    Column.text('author_user_id'),
    Column.text('parent_team_id'),
    Column.text('parent_project_id'),
    Column.text('estimated_duration_minutes'),
  ]),
  Table(taskCommentsTable, [
    Column.text('id'),
    Column.text('author_user_id'),
    Column.text('parent_task_id'),
    Column.text('created_date'),
    Column.text('content'),
    Column.text('start_date_time'),
    Column.text('end_date_time'),
  ]),
  Table(taskUserAssignmentsTable, [
    Column.text('id'),
    Column.text('task_id'),
    Column.text('user_id'),
  ]),
];
const aiChatThreadsTable = 'ai_chat_threads';
const aiChatMessagesTable = 'ai_chat_messages';

const aiChatSchemas = [
  Table(aiChatThreadsTable, [
    Column.text('id'),
    Column.text('author_user_id'),
    Column.text('name'),
    Column.text('created_at'),
    Column.text('summary'),
  ]),
  Table(aiChatMessagesTable, [
    Column.text('id'),
    Column.text('type'),
    Column.text('created_at'),
    Column.text('content'),
    Column.text('parent_chat_thread_id'),
  ]),
];

Schema schema = const Schema([
  ...permissionSchemas,
  ...tasksSchemas,
  ...aiChatSchemas,
]);