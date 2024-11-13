import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_state_provider.dart';

/// Provider for the current route
final currentRouteProvider = StateNotifierProvider<CurrentRouteNotifier, String>(
  (ref) => CurrentRouteNotifier(ref),
);

class CurrentRouteNotifier extends StateNotifier<String> {
  CurrentRouteNotifier(this.ref) : super('/');

  final Ref ref;
  
  void setCurrentRoute(String route) {
    state = route;
  }
}

/// Observer of current route that updates the current route provider
class CurrentRouteObserver extends NavigatorObserver {
  final CurrentRouteNotifier routeNotifier;

  CurrentRouteObserver(this.routeNotifier);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateRoute(route.settings.name ?? '/');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _updateRoute(newRoute?.settings.name ?? '/');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateRoute(previousRoute?.settings.name ?? '/');
  }

  void _updateRoute(String newRoute) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      routeNotifier.setCurrentRoute(newRoute);
    });
  }
}