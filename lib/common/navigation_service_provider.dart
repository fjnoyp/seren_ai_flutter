import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';

final navigationServiceProvider = Provider((ref) => NavigationService(ref));

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final Ref ref;

  NavigationService(this.ref);

  // Maximum number of retries for navigation operations
  static const int maxRetries = 3;

  // Base delay for exponential backoff (in milliseconds)
  static const int baseDelayMs = 100;

  Future<dynamic> navigateTo(
    String routeName, {
    Object? arguments,

    /// If true, the current route will be replaced with the new route
    bool withReplacement = false,

    /// If true, the stack will be cleared before navigating to the new route
    /// This is useful for auth cases, for example
    bool clearStack = false,
    int retryCount = 0,
  }) async {
    try {
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
    } catch (e) {
      // If we encounter a lock error and haven't exceeded max retries
      if (e.toString().contains('Failed to acquire lock') &&
          retryCount < maxRetries) {
        // Calculate delay with exponential backoff
        final delay = baseDelayMs * (1 << retryCount);
        log('Navigation lock error, retrying in ${delay}ms (attempt ${retryCount + 1}/$maxRetries)');

        // Wait before retrying
        await Future.delayed(Duration(milliseconds: delay));

        // Retry with incremented retry count
        return navigateTo(
          routeName,
          arguments: arguments,
          withReplacement: withReplacement,
          clearStack: clearStack,
          retryCount: retryCount + 1,
        );
      } else {
        // If it's not a lock error or we've exceeded retries, rethrow
        log('Navigation error: $e');
        rethrow;
      }
    }
  }

  bool get canPop => navigatorKey.currentState!.canPop();

  Future<dynamic> pop([dynamic result]) async {
    if (!navigatorKey.currentState!.mounted) return result;
    try {
      if (canPop) {
        navigatorKey.currentState!.pop(result);
        return result;
      } else {
        // in case the user has opened the app from a link
        // or has refreshed the page,
        // the stack will be empty, so we need to navigate to the home screen
        // when it tries to pop.
        navigateTo(AppRoutes.home.name, clearStack: true);
        return result;
      }
    } catch (e) {
      // If we encounter a lock error
      if (e.toString().contains('Failed to acquire lock')) {
        log('Navigation lock error during pop, retrying with delay');

        // Wait a bit before retrying
        await Future.delayed(const Duration(milliseconds: baseDelayMs));

        // Retry the pop operation
        return pop(result);
      } else {
        // If it's not a lock error, rethrow
        log('Pop error: $e');
        rethrow;
      }
    }
  }

  Future<dynamic> showPopupDialog(
    Widget dialog, {
    bool barrierDismissible = true,
    bool applyBarrierColor = true,
  }) async {
    try {
      return await showDialog(
        context: context,
        builder: (context) => dialog,
        barrierDismissible: barrierDismissible,
        barrierColor: applyBarrierColor ? null : Colors.transparent,
      );
    } catch (e) {
      // If we encounter a lock error
      if (e.toString().contains('Failed to acquire lock')) {
        log('Dialog lock error, retrying with delay');

        // Wait a bit before retrying
        await Future.delayed(const Duration(milliseconds: baseDelayMs));

        // Retry showing the dialog
        return showPopupDialog(
          dialog,
          barrierDismissible: barrierDismissible,
          applyBarrierColor: applyBarrierColor,
        );
      } else {
        // If it's not a lock error, rethrow
        log('Dialog error: $e');
        rethrow;
      }
    }
  }

  BuildContext get context => navigatorKey.currentState!.context;
}
