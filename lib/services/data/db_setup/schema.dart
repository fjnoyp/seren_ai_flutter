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
    Column.text('address'),
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
    Column.text('status'),
    Column.text('priority'),
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

const shiftsTable = 'shifts';
const shiftUserAssignmentsTable = 'shift_user_assignments';
const shiftTimeframesTable = 'shift_timeframes';
const shiftLogsTable = 'shift_logs';
const shiftOverridesTable = 'shift_overrides';

const shiftSchemas = [
  Table(shiftsTable, [
    Column.text('id'),
    Column.text('name'),
    Column.text('author_user_id'),
    Column.text('parent_team_id'),
    Column.text('parent_project_id'),
  ]),
  Table(shiftUserAssignmentsTable, [
    Column.text('id'),
    Column.text('shift_id'),
    Column.text('user_id'),
  ]),
  Table(shiftTimeframesTable, [
    Column.text('id'),
    Column.text('shift_id'),
    Column.integer('day_of_week'),
    Column.text('start_time'),
    Column.text('duration'),
    //Column.text('timezone'),
  ]),
  Table(shiftLogsTable, [
    Column.text('id'),
    Column.text('user_id'),
    Column.text('shift_id'),
    Column.text('clock_in_datetime'),
    Column.text('clock_out_datetime'),
    Column.integer('is_break'),
  ]),
  Table(shiftOverridesTable, [
    Column.text('id'),
    Column.text('user_id'),
    Column.text('shift_id'),
    Column.text('start_datetime'),
    Column.text('end_datetime'),
    Column.integer('is_removal'),
  ]),
];


const notesTable = 'notes';
const noteFoldersTable = 'note_folders';

const noteSchemas = [
  Table(notesTable, [
    Column.text('id'),
    Column.text('author_user_id'),
    Column.text('name'),
    Column.text('date'),
    Column.text('address'),
    Column.text('description'),
    Column.text('action_required'),
    Column.text('status'),
    Column.text('parent_note_folder_id'),
  ]),
  Table(noteFoldersTable, [
    Column.text('id'),
    Column.text('name'),
    Column.text('description'),
    Column.text('parent_team_id'),
    Column.text('parent_project_id'),
    Column.integer('estimated_duration_minutes'),
  ]),
];

// Go through all the tables and add a Column.text('created_at') and Column.text('updated_at') to each table

const allTables = [
  ...permissionSchemas,
  ...tasksSchemas,
  ...aiChatSchemas,
  ...shiftSchemas,
  ...noteSchemas,
];

// Create a function to add timestamp columns
List<Table> addTimestampColumns(List<Table> tables) {
  return tables.map((table) {
    return Table(
      table.name,
      [
        ...table.columns,
        const Column.text('created_at'),
        const Column.text('updated_at'),
      ],
    );
  }).toList();
}

// Apply the function to all tables
final tablesWithTimestamps = addTimestampColumns(allTables);

Schema schema = Schema(tablesWithTimestamps);
