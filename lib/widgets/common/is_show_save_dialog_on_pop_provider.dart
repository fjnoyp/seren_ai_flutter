import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO p2: auto save in task and note pages 
// For now we have a provider to check if we can save
// and then we use that in the main scaffold to enable/disable the modal 
final isShowSaveDialogOnPopProvider = NotifierProvider<IsShowSaveDialogNotifier, bool>(() {
  return IsShowSaveDialogNotifier();
});

class IsShowSaveDialogNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setCanSave(bool canSave) {
    state = canSave;
  }

  void reset() {
    state = false;
  }
}