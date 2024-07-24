import 'package:powersync/powersync.dart';


const usersTable = 'users';
const orgsTable = 'orgs';
const teamsTable = 'teams';
const projectsTable = 'projects';
const userOrgRolesTable = 'user_org_roles';
const userTeamRolesTable = 'user_team_roles';
const userProjectRolesTable = 'user_project_roles';

Schema schema = const Schema([
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
]);