import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/widgets/auth_guard.dart';
import 'package:seren_ai_flutter/services/auth/widgets/sign_in_up_page.dart';
import 'package:seren_ai_flutter/services/auth/widgets/terms_and_conditions_webview.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/ai_chats_page.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/notes_list_page.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/choose_org_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/manage_org_users_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/org_guard.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/projects_page.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/shifts_page.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/services/ai_interaction/stt_orchestrator_provider.dart.dart';
import 'package:seren_ai_flutter/widgets/home/home_page.dart';
import 'package:seren_ai_flutter/widgets/common/main_scaffold.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/tasks_list_page.dart';
import 'package:seren_ai_flutter/widgets/test_page.dart';
import 'package:seren_ai_flutter/widgets/test_sql_page.dart';
import 'package:seren_ai_flutter/widgets/common/theme_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final log = Logger('App');

class App extends StatefulWidget {
  const App({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinkListener();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // Initiate the orchestrator
        ref.read(sttOrchestratorProvider);

        //final firstUserValue = ref.read(curAuthUserProvider);
        final initialRoute = Supabase.instance.client.auth.currentUser == null
            ? signInUpRoute
            : tasksRoute;

        final themeMode = ref.watch(themeSNP);

        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          initialRoute: initialRoute,
          routes: {
            signInUpRoute: (context) => const MainScaffold(
                title: 'Sign In/Up',
                body: SignInUpPage(),
                showBottomBar: false),
            homeRoute: (context) => const _GuardScaffold('Home', HomePage()),
            chooseOrgRoute: (context) => const _AuthGuardScaffold(
                'Choose Organization', ChooseOrgPage()),
            manageOrgUsersRoute: (context) => const _GuardScaffold(
                'Manage Organization Users', ManageOrgUsersPage()),
            projectsRoute: (context) =>
                const _GuardScaffold('Projects', ProjectsPage()),
            tasksRoute: (context) =>
                const _GuardScaffold('Tasks', TasksListPage()),
            taskPageRoute: (context) {
              // TODO p3: add taskId to args
              // Cannot use implicits or else dynamic routes will not work
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
              final mode = args['mode'] as EditablePageMode;
              final title =
                  mode == EditablePageMode.create ? 'Create Task' : 'View Task';

              return _GuardScaffold(title, TaskPage(mode: mode));
            },
            aiChatsRoute: (context) =>
                const _GuardScaffold('AI Chat Page', AIChatsPage()),
            shiftsRoute: (context) =>
                const _GuardScaffold('Shifts', ShiftsPage()),
            testRoute: (context) => const _GuardScaffold('Test', TestPage()),
            testSQLPageRoute: (context) =>
                _GuardScaffold('Test SQL Page', TestSQLPage()),
            noteListRoute: (context) =>
                const _GuardScaffold('Notes', NoteListPage()),
            notePageRoute: (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
              final mode = args['mode'] as EditablePageMode;
              final title =
                  mode == EditablePageMode.create ? 'Create Note' : 'View Note';

              return _GuardScaffold(title, NotePage(mode: mode));
            },
            termsAndConditionsRoute: (context) => const TermsAndConditionsWebview(),
          },
          // For dynamically generating routes based on settings param
          onGenerateRoute: (settings) {
            /*
            if (settings.name == '/test') {
              final param = settings.arguments as String?;
              return MaterialPageRoute(
                builder: (context) {
                  return TestPage(param: param);
                },
              );
            } else if (settings.name == '/test2') {
              final args = settings.arguments as Map<String, String?>;
              return MaterialPageRoute(
                builder: (context) {
                  return Test2Page(args: args);
                },
              );
            }
            */
            // Handle other routes here if needed
            return null;
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en' /*, 'US'*/),
            Locale('pt', 'PT'),
            Locale('pt', 'BR'),
          ],
        );
      },
    );
  }

  void _initDeepLinkListener() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }

      _appLinks.uriLinkStream.listen((uri) {
        _handleDeepLink(uri);
      });
    } on Exception catch (e) {
      log.severe('Failed to get initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    // Handle the deep link here
    log.info('Received deep link: $uri');

    /*
    // Example: Navigate to a specific screen based on the link
    if (uri.path.startsWith('/test')) {
      final param = uri.queryParameters['param'];
      Navigator.pushNamed(context, '/test', arguments: param);
    } else if (uri.path.startsWith('/test2')) {
      final param1 = uri.queryParameters['param1'];
      final param2 = uri.queryParameters['param2'];
      Navigator.pushNamed(context, '/test2',
          arguments: {'param1': param1, 'param2': param2});
    } else {
      print('Unknown deep link: $uri');
    }
    */
  }
}

class _AuthGuardScaffold extends StatelessWidget {
  const _AuthGuardScaffold(this.title, this.body);

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return AuthGuard(child: MainScaffold(title: title, body: body));
  }
}

class _GuardScaffold extends StatelessWidget {
  const _GuardScaffold(this.title, this.body);

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: OrgGuard(
        child: MainScaffold(title: title, body: body),
      ),
    );
  }
}
