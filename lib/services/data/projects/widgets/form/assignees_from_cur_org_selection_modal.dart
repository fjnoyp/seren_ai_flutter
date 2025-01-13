import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_role_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

class AssigneesFromCurOrgSelectionModal extends HookConsumerWidget {
  final List<UserModel> initialSelectedUsers;
  final Future<void> Function(WidgetRef, List<UserModel>) onAssigneesChanged;

  const AssigneesFromCurOrgSelectionModal({
    super.key,
    required this.initialSelectedUsers,
    required this.onAssigneesChanged,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentlySelectedUsers = useState(initialSelectedUsers);
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    return AsyncValueHandlerWidget(
      value: ref.watch(joinedCurOrgRolesProvider),
      data: (joinedCurOrgRoles) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.onlyUsersIn),
                    Text(joinedCurOrgRoles.first.org!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(AppLocalizations.of(context)!.canBeAssigned),
                  ],
                ),
                const SizedBox(height: 16),
                SearchBar(
                  controller: searchController,
                  leading: const Icon(Icons.search),
                  hintText: AppLocalizations.of(context)!.search,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: joinedCurOrgRoles.length,
                    itemBuilder: (context, index) {
                      final user = joinedCurOrgRoles[index].user!;
                      if (!(user.firstName
                              .toLowerCase()
                              .contains(searchQuery.value.toLowerCase()) ||
                          user.lastName
                              .toLowerCase()
                              .contains(searchQuery.value.toLowerCase()) ||
                          user.email
                              .toLowerCase()
                              .contains(searchQuery.value.toLowerCase()))) {
                        return const SizedBox.shrink();
                      }
                      final isSelected =
                          currentlySelectedUsers.value.contains(user);
                      return CheckboxListTile(
                        value: isSelected,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text('${user.firstName} ${user.lastName}'),
                        onChanged: (bool? value) {
                          if (value != null) {
                            final updatedUsers = List<UserModel>.from(
                                currentlySelectedUsers.value);
                            if (value) {
                              updatedUsers.add(user);
                            } else {
                              updatedUsers.remove(user);
                            }
                            currentlySelectedUsers.value = updatedUsers;
                          }
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await onAssigneesChanged(ref, currentlySelectedUsers.value);
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
