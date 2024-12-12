import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_roles_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/update_project_assignees_button.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/providers/users_in_project_provider.dart';

class BaseAssigneesSelectionField extends HookConsumerWidget {
  final bool enabled;
  final ProviderListenable<List<UserModel>> assigneesProvider;
  final ProviderListenable<ProjectModel?> projectProvider;
  final Function(WidgetRef, List<UserModel>?) updateAssignees;
  //final ProviderListenable<List<UserModel>> selectableUsersProvider;
  const BaseAssigneesSelectionField({
    super.key,
    required this.enabled,
    required this.assigneesProvider,
    required this.projectProvider,
    required this.updateAssignees,
    //required this.selectableUsersProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curAssignees = ref.watch(assigneesProvider);
    final curProject = ref.watch(projectProvider);

    return AnimatedSelectionField<List<UserModel>>(
      labelWidget: const Icon(Icons.person),
      // validator: (assignees) => assignees == null || assignees.isEmpty
      //     ? 'Assignees are required'
      //     : null,
      valueToString: (assignees) => assignees?.isEmpty == true
          ? AppLocalizations.of(context)!.chooseAssignees
          : assignees!
              .map((assignee) => '${assignee.firstName} ${assignee.lastName}')
              .join(', '),
      enabled: enabled && curProject != null,
      value: curAssignees,
      onValueChanged: updateAssignees,
      showSelectionModal: (BuildContext context) async {
        showModalBottomSheet<List<UserModel>>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return AssigneesSelectionModal(
              initialSelectedUsers: curAssignees,
              onAssigneesChanged: updateAssignees,
              //selectableUsersProvider: selectableUsersProvider,
              projectProvider: projectProvider,
            );
          },
        );
        return null;
      },
    );
  }
}

class AssigneesSelectionModal extends HookConsumerWidget {
  final List<UserModel> initialSelectedUsers;
  final void Function(WidgetRef, List<UserModel>) onAssigneesChanged;
  //final ProviderListenable<List<UserModel>> selectableUsersProvider;
  final ProviderListenable<ProjectModel?> projectProvider;

  const AssigneesSelectionModal({
    super.key,
    required this.initialSelectedUsers,
    required this.onAssigneesChanged,
    //required this.selectableUsersProvider,
    required this.projectProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curProject = ref.watch(projectProvider);

    if (curProject == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AsyncValueHandlerWidget(
      value: ref.watch(usersInProjectProvider(curProject.id)),
      data: (users) => Padding(
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
                  Text(curProject.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(AppLocalizations.of(context)!.canBeAssigned),
                ],
              ),
              if (ref.read(curUserOrgRoleProvider).value == OrgRole.admin ||
                  ref.read(curUserOrgRoleProvider).value == OrgRole.editor)
                ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return const UpdateProjectAssigneesModal();
                    },
                  ),
                  child: Text(AppLocalizations.of(context)!
                      .addUsersTo(curProject.name)),
                ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSelected =
                        initialSelectedUsers.contains(user);
                    return CheckboxListTile(
                      title: Text('${user.firstName} ${user.lastName}'),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: isSelected,
                      onChanged: (bool? value) {
                        if (value != null) {
                          final updatedUsers = List<UserModel>.from(
                              initialSelectedUsers);
                          if (value) {
                            updatedUsers.add(user);
                          } else {
                            updatedUsers.remove(user);
                          }
                          onAssigneesChanged(ref, updatedUsers);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
