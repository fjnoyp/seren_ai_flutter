import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/language_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/main.dart';
import 'package:seren_ai_flutter/services/ai/widgets/testing/test_ai_page.dart';
import 'package:seren_ai_flutter/services/auth/widgets/auth_guard.dart';
import 'package:seren_ai_flutter/services/auth/widgets/onboarding/no_invites_page.dart';
import 'package:seren_ai_flutter/services/auth/widgets/onboarding/onboarding_page.dart';
import 'package:seren_ai_flutter/services/auth/widgets/reset_password/reset_password_page.dart';
import 'package:seren_ai_flutter/services/auth/widgets/sign_in_up_page.dart';
import 'package:seren_ai_flutter/services/auth/widgets/terms_and_conditions/terms_and_conditions_webview.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/widgets/ai_chats_page.dart';
import 'package:seren_ai_flutter/services/data/common/base_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/notes_list_page.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/choose_org_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/cur_org_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/manage_org_users_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/org_guard.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/org_invite_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/web/web_manage_org_users_page.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/unused_project_list_page.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/project_overview_page.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_details_page.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/shifts_page.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/gantt_task_page.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/services/ai/stt_orchestrator_provider.dart.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/web/web_task_page.dart';
import 'package:seren_ai_flutter/services/notifications/helpers/fcm_push_notification_handler.dart';
import 'package:seren_ai_flutter/services/notifications/services/fcm_device_token_service.dart';
import 'package:seren_ai_flutter/services/notifications/widgets/notifications_page.dart';
import 'package:seren_ai_flutter/widgets/home/home_page.dart';
import 'package:seren_ai_flutter/widgets/scaffold/main_scaffold.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/unused_tasks_list_page.dart';
import 'package:seren_ai_flutter/widgets/settings/settings_page.dart';
import 'package:seren_ai_flutter/widgets/settings/web/web_settings_page.dart';
import 'package:seren_ai_flutter/widgets/debug/test_sql_page.dart';
import 'package:seren_ai_flutter/widgets/common/theme_data.dart';

final log = Logger('App');

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => AppState();
}

class AppState extends ConsumerState<App> {
  late final CurrentRouteObserver _routeObserver;

  @override
  void initState() {
    super.initState();
    _routeObserver =
        CurrentRouteObserver(ref.read(currentRouteProvider.notifier));
    _initDeepLinkListener(ref);

    final fcmTokenService = ref.read(fcmDeviceTokenServiceProvider);
    fcmTokenService.initialize();

    // Set up FCM navigation after provider scope is ready
    FCMPushNotificationHandler.instance.setupNavigation(ref);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // === Permanent Providers ===
        ref.read(sttOrchestratorProvider);
        ref.read(curShiftStateProvider);

        final themeMode = ref.watch(themeSNP);

        final languageString = ref.watch(languageSNP);
        final parts = languageString.split('_');
        final languageCode = parts.isNotEmpty ? parts[0] : 'en';
        final countryCode = parts.length > 1 ? parts[1] : null;

        return MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          initialRoute: AppRoutes.home.name,
          // Context-less navigation setup
          navigatorKey: ref.read(navigationServiceProvider).navigatorKey,
          // Watching current route setup
          navigatorObservers: [_routeObserver],
          // For dynamically generating routes based on settings param
          onGenerateRoute: (settings) {
            final uri = Uri.parse(settings.name ?? '');
            final args = settings.arguments as Map<String, dynamic>?;

            final routes = {
              AppRoutes.signInUp.name: (context) => Scaffold(
                  appBar: AppBar(
                      title: Text(AppLocalizations.of(context)!.signInUp),
                      centerTitle: true),
                  body: const SignInUpPage()),
              AppRoutes.home.name: (context) => _GuardScaffold(
                  AppLocalizations.of(context)!.home,
                  HomePage(
                    initialTab:
                        args != null ? args['initialTab'] as int? : null,
                  )),
              AppRoutes.chooseOrg.name: (context) => _AuthGuardScaffold(
                  AppLocalizations.of(context)!.chooseOrganization,
                  const ChooseOrgPage()),
              AppRoutes.organization.name: (context) => _GuardScaffold(
                    AppLocalizations.of(context)!.organization,
                    CurOrgPage(
                        mode: args?['mode'] ?? EditablePageMode.readOnly),
                    actions: args?['actions'],
                  ),
              AppRoutes.manageOrgUsers.name: (context) => _GuardScaffold(
                    AppLocalizations.of(context)!.manageOrgUsers,
                    const ManageOrgUsersPage(),
                    actions: args?['actions'],
                    webBody: const WebManageOrgUsersPage(),
                  ),
              AppRoutes.projects.name: (context) => _GuardScaffold(
                  AppLocalizations.of(context)!.projects,
                  const ProjectListPage()),
              AppRoutes.projectOverview.name: (context) => _GuardScaffold(
                    args?['title'] ?? AppLocalizations.of(context)!.project,
                    const ProjectOverviewPage(),
                    actions: args?['actions'],
                  ),
              AppRoutes.projectDetails.name: (context) => _GuardScaffold(
                    args?['title'] ?? AppLocalizations.of(context)!.project,
                    ProjectDetailsPage(
                      mode: args?['mode'] ?? EditablePageMode.readOnly,
                    ),
                    actions: args?['actions'],
                  ),
              AppRoutes.tasks.name: (context) => _GuardScaffold(
                  AppLocalizations.of(context)!.tasks, const TasksListPage()),
              AppRoutes.taskPage.name: (context) => _GuardScaffold(
                    args?['title'] ?? AppLocalizations.of(context)!.task,
                    TaskPage(mode: args?['mode'] ?? EditablePageMode.edit),
                    actions: args?['actions'],
                    webBody: const WebTaskPage(),
                  ),
              AppRoutes.aiChats.name: (context) => _GuardScaffold(
                    AppLocalizations.of(context)!.aiChatThreads,
                    const AIChatsPage(),
                    showBottomBar: false,
                  ),
              AppRoutes.shifts.name: (context) => _GuardScaffold(
                  AppLocalizations.of(context)!.shifts, const ShiftsPage()),
              AppRoutes.testSQLPage.name: (context) => _GuardScaffold(
                  AppLocalizations.of(context)!.testSQL, TestSQLPage()),
              AppRoutes.testAiPage.name: (context) =>
                  const _GuardScaffold("Test AI", TestAiPage()),
              AppRoutes.noteList.name: (context) => _GuardScaffold(
                  AppLocalizations.of(context)!.notes, const NoteListPage()),
              AppRoutes.notePage.name: (context) => _GuardScaffold(
                    args?['title'] ?? AppLocalizations.of(context)!.note,
                    NotePage(mode: args?['mode'] ?? EditablePageMode.edit),
                    actions: args?['actions'],
                  ),
              AppRoutes.termsAndConditions.name: (context) =>
                  const TermsAndConditionsWebview(),
              AppRoutes.taskGantt.name: (context) =>
                  const _GuardScaffold('Gantt', GanttTaskPage()),
              AppRoutes.settings.name: (context) => _GuardScaffold(
                    AppLocalizations.of(context)!.settings,
                    const SettingsPage(),
                    webBody: const WebSettingsPage(),
                    showBottomBar: false,
                  ),
              AppRoutes.resetPassword.name: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text(AppLocalizations.of(context)!.resetPassword),
                      centerTitle: true,
                    ),
                    body: ResetPasswordPage((ModalRoute.of(context)!
                        .settings
                        .arguments as Map<String, dynamic>)['accessToken']),
                  ),
              AppRoutes.notifications.name: (context) => _GuardScaffold(
                    AppLocalizations.of(context)!.notifications,
                    const NotificationsPage(),
                  ),
              AppRoutes.onboarding.name: (context) => const AuthGuard(
                    child: OnboardingPage(),
                  ),
              AppRoutes.noInvites.name: (context) => const AuthGuard(
                    child: NoInvitesPage(),
                  ),
              AppRoutes.orgInvite.name: (context) => AuthGuard(
                    child: OrgInvitePage(orgId: args?['orgId']),
                  ),
            };

            final MapEntry(key: path, value: builder) =
                routes.entries.firstWhere(
              (e) =>
                  e.key.replaceAll('/', '') == uri.pathSegments[0] ||
                  e.key == settings.name,
              orElse: () =>
                  throw Exception('Route not found: ${settings.name}'),
            );

            // Handle routes with ID - set the ID if needed
            if (uri.pathSegments.length > 1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (AppRoutes.getAppRouteFromPath(path) case AppRoutes route) {
                  final navigationService =
                      BaseNavigationService.fromAppRoute(route, ref);
                  if (navigationService == null) {
                    log.severe(
                        'Navigation service not found for ${route.name}');
                    return;
                  }
                  final curSelectedId =
                      ref.read(navigationService.idNotifierProvider);

                  if (curSelectedId == null) {
                    try {
                      log.info('Setting ID function: ${uri.pathSegments[1]}');
                      // Use await to ensure the promise rejection is caught
                      Future(() async {
                        try {
                          await navigationService
                              .setIdFunction(uri.pathSegments[1]);
                        } catch (e) {
                          log.severe('Error setting ID function: $e');
                          final appNavigationService =
                              ref.read(navigationServiceProvider);

                          // Navigate first
                          appNavigationService.navigateTo(AppRoutes.home.name);

                          // After navigation completes, show the SnackBar
                          // We'll use a slight delay to ensure the new route is fully built
                          Future.delayed(const Duration(milliseconds: 300), () {
                            final messenger = ScaffoldMessenger.of(
                                appNavigationService
                                    .navigatorKey.currentContext!);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'You\'re not allowed to access that page.'),
                              ),
                            );
                          });
                        }
                      });
                    } catch (e) {
                      // This will catch synchronous errors
                      log.severe('Error setting ID function: $e');
                      // Navigate first
                      ref
                          .read(navigationServiceProvider)
                          .navigateTo(AppRoutes.home.name);
                      // After navigation completes, show the SnackBar
                      Future.delayed(const Duration(milliseconds: 300), () {
                        final messenger = ScaffoldMessenger.of(ref
                            .read(navigationServiceProvider)
                            .navigatorKey
                            .currentContext!);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Error trying to open the page. Please try again later.'),
                          ),
                        );
                      });
                    }
                  }
                }
              });
            }

            // Replace MaterialPageRoute with PageRouteBuilder
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, _, __) => builder(context),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            );
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

  void _initDeepLinkListener(WidgetRef ref) async {
    final appLinks = AppLinks();

    try {
      final initialLink = await appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(ref, initialLink);
      }

      appLinks.uriLinkStream.listen((uri) {
        _handleDeepLink(ref, uri);
      });
    } on Exception catch (e) {
      log.severe('Failed to get initial link: $e');
    }
  }

  void _handleDeepLink(WidgetRef ref, Uri uri) {
    // Handle the deep link here
    log.info('Received deep link: $uri');

    if (uri.host == 'reset-password') {
      ref.read(navigationServiceProvider).navigateTo(
          AppRoutes.resetPassword.name,
          arguments: {'accessToken': uri.queryParameters['code']});
    }
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
  });

  final String title;
  final Widget body;
  final Widget? webBody;
  final List<Widget>? actions;
  final bool showBottomBar;

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: OrgGuard(
        child: MainScaffold(
          title: title,
          body: isWebVersion ? webBody ?? body : body,
          actions: actions,
          showBottomBar: showBottomBar,
        ),
      ),
    );
  }
}
