import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/auth/widgets/auth_guard.dart';
import 'package:seren_ai_flutter/services/auth/widgets/sign_in_up_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/choose_org_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/manage_org_users_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/org_guard.dart';
import 'package:seren_ai_flutter/widgets/home_page.dart';
import 'package:seren_ai_flutter/widgets/main_scaffold.dart';
import 'package:seren_ai_flutter/widgets/tasks_page.dart';
import 'package:seren_ai_flutter/widgets/test_page.dart';
import 'package:seren_ai_flutter/widgets/theme_data.dart';

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

  Widget _buildGuardScaffold(String title, Widget body) {
    return AuthGuard(child: 
            OrgGuard(child:
              MainScaffold(title: title, body: body)));
  }

  Widget _buildAuthGuardScaffold(String title, Widget body) {
    return AuthGuard(child: 
            MainScaffold(title: title, body: body));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      // Initiate the orchestrator
      //ref.read(sttToLangchainOrchestrator);

      final firstUserValue = ref.read(curAuthUserProvider);
      final initialRoute = firstUserValue == null ? signInUpRoute : tasksRoute;

      final themeMode = ref.watch(themeSNP);

      return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          initialRoute: initialRoute,          
          routes: {
            chooseOrgRoute: (context) => _buildAuthGuardScaffold('Choose Organization', const ChooseOrgPage()),
            manageOrgUsersRoute: (context) => _buildGuardScaffold('Manage Organization Users', const ManageOrgUsersPage()),
            testRoute: (context) => _buildGuardScaffold('Test', const TestPage()),
            tasksRoute: (context) => _buildGuardScaffold('Tasks', const TasksPage()),
            signInUpRoute: (context) => const SignInUpPage(),
            homeRoute: (context) => _buildGuardScaffold('Home', const HomePage()),
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
          });
    });
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
