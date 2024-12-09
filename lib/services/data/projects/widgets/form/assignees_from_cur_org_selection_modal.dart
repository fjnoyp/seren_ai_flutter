import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_roles_provider.dart';
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

    return AsyncValueHandlerWidget(
      value: ref.watch(joinedCurOrgRolesProvider),
      data: (joinedCurOrgRoles) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
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
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: ListView.builder(
                  itemCount: joinedCurOrgRoles.length,
                  itemBuilder: (context, index) {
                    final user = joinedCurOrgRoles[index].user!;
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
      ),
    );
  }
}
