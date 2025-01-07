import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/is_show_save_dialog_on_pop_provider.dart';
import 'package:seren_ai_flutter/widgets/common/confirm_save_dialog.dart';

final navigationServiceProvider = Provider((ref) => NavigationService(ref));

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final Ref ref;

  NavigationService(this.ref);

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateToWithReplacement(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateToAndRemoveUntil(
      String routeName, bool Function(Route<dynamic>) predicate,
      {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
  }

  void popUntil(bool Function(Route<dynamic>) predicate) {
    navigatorKey.currentState!.popUntil(predicate);
  }

  bool get canPop => navigatorKey.currentState!.canPop();

  Future<dynamic> pop([dynamic result]) async {
    if (!navigatorKey.currentState!.mounted) return result;

    final canSave = ref.read(isShowSaveDialogOnPopProvider);

    if (!canSave) {
      if (canPop) {
        navigatorKey.currentState!.pop(result);
        return result;
      }
    } else {
      // If can save - show dialog to confirm save
      final shouldSave = await showPopupDialog(const ConfirmSaveDialog());

      if (shouldSave ?? false) {
        ref.read(isShowSaveDialogOnPopProvider.notifier).reset();
        if (canPop) {
          navigatorKey.currentState!.pop(result);
          return result;
        }
      }
      // If user cancels, don't pop and return null
      return null;
    }
  }

  Future<dynamic> navigateToWithPopUntil(
    String routeName, {
    Object? arguments,
    required bool Function(Route<dynamic>) predicate,
  }) async {
    popUntil(predicate);
    return navigateTo(routeName, arguments: arguments);
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
