import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationServiceProvider = Provider((ref) => NavigationService(ref));

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final Ref ref;

  NavigationService(this.ref);

  Future<dynamic> navigateTo(
    String routeName, {
    Object? arguments,

    /// If true, the current route will be replaced with the new route
    bool withReplacement = false,

    /// If true, the stack will be cleared before navigating to the new route
    /// This is useful for auth cases, for example
    bool clearStack = false,
  }) {
    if (clearStack) {
      return navigatorKey.currentState!.pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
        arguments: arguments,
      );
    }
    if (withReplacement) {
      return navigatorKey.currentState!
          .pushReplacementNamed(routeName, arguments: arguments);
    }
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  bool get canPop => navigatorKey.currentState!.canPop();

  Future<dynamic> pop([dynamic result]) async {
    if (!navigatorKey.currentState!.mounted) return result;
    if (canPop) {
      navigatorKey.currentState!.pop(result);
      return result;
    }
  }

  Future<dynamic> showPopupDialog(Widget dialog,
      {bool barrierDismissible = true}) async {
    return await showDialog(
      context: context,
      builder: (context) => dialog,
      barrierDismissible: barrierDismissible,
    );
  }

  BuildContext get context => navigatorKey.currentState!.context;
}
