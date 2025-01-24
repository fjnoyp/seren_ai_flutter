import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/language_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/auth/widgets/auth_guard.dart';
import 'package:seren_ai_flutter/services/auth/widgets/sign_in_up_page.dart';
import 'package:seren_ai_flutter/services/auth/widgets/terms_and_conditions/terms_and_conditions_webview.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/ai_chats_page.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/notes_list_page.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/choose_org_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/cur_org_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/manage_org_users_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/org_guard.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/web/web_manage_org_users_page.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_page.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_list_page.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/web/web_project_page.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/shifts_page.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_schedule_notifications_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/gantt_task_page.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/services/ai_interaction/stt_orchestrator_provider.dart.dart';
import 'package:seren_ai_flutter/widgets/home/home_page.dart';
import 'package:seren_ai_flutter/widgets/common/main_scaffold.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/tasks_list_page.dart';
import 'package:seren_ai_flutter/widgets/settings/settings_page.dart';
import 'package:seren_ai_flutter/widgets/settings/web/web_settings_page.dart';
import 'package:seren_ai_flutter/widgets/test_sql_page.dart';
import 'package:seren_ai_flutter/widgets/common/theme_data.dart';

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
        // === Permanent Providers ===
        ref.read(sttOrchestratorProvider);
        ref.read(curShiftStateProvider);
        if (!kIsWeb) {
          ref.read(taskScheduleNotificationsServiceProvider);
        }

        final themeMode = ref.watch(themeSNP);

        final languageString = ref.watch(languageSNP);
        final parts = languageString.split('_');
        final languageCode = parts.isNotEmpty ? parts[0] : 'en';
        final countryCode = parts.length > 1 ? parts[1] : null;

        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          initialRoute: AppRoutes.home.name,
          // Context-less navigation setup
          navigatorKey: ref.read(navigationServiceProvider).navigatorKey,
          // Watching current route setup
          navigatorObservers: [
            CurrentRouteObserver(ref.read(currentRouteProvider.notifier))
          ],
          routes: {
            AppRoutes.signInUp.name: (context) => Scaffold(
                appBar: AppBar(
                    title: Text(AppLocalizations.of(context)!.signInUp),
                    centerTitle: true),
                body: const SignInUpPage()),
            AppRoutes.home.name: (context) => _GuardScaffold(
                AppLocalizations.of(context)!.home, const HomePage()),
            AppRoutes.chooseOrg.name: (context) => _AuthGuardScaffold(
                AppLocalizations.of(context)!.chooseOrganization,
                const ChooseOrgPage()),
            AppRoutes.organization.name: (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
              return _GuardScaffold(
                AppLocalizations.of(context)!.organization,
                CurOrgPage(mode: args?['mode'] ?? EditablePageMode.readOnly),
                actions: args?['actions'],
              );
            },
            AppRoutes.manageOrgUsers.name: (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
              return _GuardScaffold(
                AppLocalizations.of(context)!.manageOrgUsers,
                const ManageOrgUsersPage(),
                actions: args['actions'],
                webBody: const WebManageOrgUsersPage(),
                showAppBar: !isWebVersion,
              );
            },
            AppRoutes.projects.name: (context) => _GuardScaffold(
                AppLocalizations.of(context)!.projects,
                const ProjectListPage()),
            AppRoutes.projectDetails.name: (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
              return _GuardScaffold(
                args['title'],
                ProjectPage(mode: args['mode'] ?? EditablePageMode.readOnly),
                webBody: const WebProjectPage(),
                actions: args['actions'],
                showAppBar: !isWebVersion,
              );
            },
            AppRoutes.tasks.name: (context) => _GuardScaffold(
                AppLocalizations.of(context)!.tasks, const TasksListPage()),
            AppRoutes.taskPage.name: (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;

              return _GuardScaffold(
                args['title'],
                TaskPage(mode: args['mode']),
                actions: args['actions'],
                showAppBar: !isWebVersion,
              );
            },
            AppRoutes.aiChats.name: (context) => _GuardScaffold(
                  AppLocalizations.of(context)!.aiChatThreads,
                  const AIChatsPage(),
                  showBottomBar: false,
                  showAppBar: false,
                ),
            AppRoutes.shifts.name: (context) => _GuardScaffold(
                AppLocalizations.of(context)!.shifts, const ShiftsPage()),
            // This page is never loaded
            // AppRoutes.test.name: (context) =>
            //     const _GuardScaffold('Test', TestPage()),
            AppRoutes.testSQLPage.name: (context) => _GuardScaffold(
                AppLocalizations.of(context)!.testSQL, TestSQLPage()),
            AppRoutes.noteList.name: (context) => _GuardScaffold(
                AppLocalizations.of(context)!.notes, const NoteListPage()),
            AppRoutes.notePage.name: (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;

              return _GuardScaffold(
                args['title'],
                NotePage(mode: args['mode']),
                actions: args['actions'],
              );
            },
            AppRoutes.termsAndConditions.name: (context) =>
                const TermsAndConditionsWebview(),
            AppRoutes.taskGantt.name: (context) =>
                const _GuardScaffold('Gantt', TaskGanttPage()),
            AppRoutes.settings.name: (context) => _GuardScaffold(
                  AppLocalizations.of(context)!.settings,
                  const SettingsPage(),
                  webBody: const WebSettingsPage(),
                  showAppBar: false,
                  showBottomBar: false,
                ),
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
          locale: Locale(languageCode, countryCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
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
      ref.read(navigationServiceProvider).navigateTo(
          '/test', arguments: param);
    } else if (uri.path.startsWith('/test2')) {
      final param1 = uri.queryParameters['param1'];
      final param2 = uri.queryParameters['param2'];
      ref.read(navigationServiceProvider).navigateTo(
          '/test2', arguments: {'param1': param1, 'param2': param2});
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
  const _GuardScaffold(
    this.title,
    this.body, {
    this.webBody,
    this.actions,
    this.showBottomBar = true,
    this.showAppBar = true,
  });

  final String title;
  final Widget body;
  final Widget? webBody;
  final List<Widget>? actions;
  final bool showBottomBar;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: OrgGuard(
        child: MainScaffold(
          title: title,
          body: isWebVersion ? webBody ?? body : body,
          actions: actions,
          showAiAssistant: showBottomBar,
          showAppBar: showAppBar,
        ),
      ),
    );
  }
}
