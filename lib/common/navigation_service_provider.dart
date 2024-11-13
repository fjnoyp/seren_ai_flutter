import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationServiceProvider = Provider((ref) => NavigationService());

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  // Add these methods
  void popUntil(bool Function(Route<dynamic>) predicate) {
    navigatorKey.currentState!.popUntil(predicate);
  }

  Future<dynamic> navigateToWithPopUntil(
    String routeName, {
    Object? arguments,
    required bool Function(Route<dynamic>) predicate,
  }) async {
    popUntil(predicate);
    return navigateTo(routeName, arguments: arguments);
  }
}