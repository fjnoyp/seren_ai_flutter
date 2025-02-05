import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_role_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/update_project_assignees_button.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/providers/user_in_project_provider.dart';

class BaseAssigneesSelectionField extends HookConsumerWidget {
  final bool enabled;
  final ProviderListenable<List<UserModel>> assigneesProvider;
  final ProviderListenable<String?> projectIdProvider;
  final Function(WidgetRef, List<UserModel>?) updateAssignees;
  final Widget Function(List<UserModel>)? assigneesWidget;
  //final ProviderListenable<List<UserModel>> selectableUsersProvider;
  const BaseAssigneesSelectionField({
    super.key,
    required this.enabled,
    required this.assigneesProvider,
    required this.projectIdProvider,
    required this.updateAssignees,
    this.assigneesWidget,
    //required this.selectableUsersProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curAssignees = ref.watch(assigneesProvider);
    final curProjectId = ref.watch(projectIdProvider);

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
      valueToWidget: assigneesWidget,
      enabled: enabled && curProjectId != null,
      value: curAssignees,
      onValueChanged: updateAssignees,

      onTap: (BuildContext context) async {
        FocusManager.instance.primaryFocus?.unfocus();
        if (isWebVersion) {
          await showDialog<List<UserModel>>(
            context: context,
            builder: (_) => AlertDialog(
              content: SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: AssigneesSelectionModal(
                  initialSelectedUsers: curAssignees,
                  onAssigneesChanged: updateAssignees,
                  //selectableUsersProvider: selectableUsersProvider,
                  projectIdProvider: projectIdProvider,
                ),
              ),
            ),
          );
        } else {
          await showModalBottomSheet<List<UserModel>>(
            context: context,
            isScrollControlled: true,
            builder: (_) => AssigneesSelectionModal(
              initialSelectedUsers: curAssignees,
              onAssigneesChanged: updateAssignees,
              //selectableUsersProvider: selectableUsersProvider,
              projectIdProvider: projectIdProvider,
            ),
          );
        }
        FocusManager.instance.primaryFocus?.unfocus();
        return null;
      },
    );
  }
}

class AssigneesSelectionModal extends HookConsumerWidget {
  final List<UserModel> initialSelectedUsers;
  final void Function(WidgetRef, List<UserModel>) onAssigneesChanged;
  //final ProviderListenable<List<UserModel>> selectableUsersProvider;
  final ProviderListenable<String?> projectIdProvider;

  const AssigneesSelectionModal({
    super.key,
    required this.initialSelectedUsers,
    required this.onAssigneesChanged,
    //required this.selectableUsersProvider,
    required this.projectIdProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curProjectId = ref.watch(projectIdProvider);

    if (curProjectId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final curProject = ref.watch(projectByIdStreamProvider(curProjectId));
    final selectedUsers = useState<List<UserModel>>(initialSelectedUsers);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 8.0),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ),
        AsyncValueHandlerWidget(
          value: ref.watch(usersInProjectProvider(curProjectId)),
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
                      Text(
                          curProject.when(
                              data: (project) => project?.name ?? '',
                              error: (e, __) => 'Err: $e',
                              loading: () => '...'),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(AppLocalizations.of(context)!.canBeAssigned),
                    ],
                  ),
                  if (ref.read(curUserOrgRoleProvider).value == OrgRole.admin ||
                      ref.read(curUserOrgRoleProvider).value == OrgRole.editor)
                    ElevatedButton(
                      onPressed: () {
                        if (isWebVersion) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                child: UpdateProjectAssigneesModal(
                                  projectId: curProjectId,
                                ),
                              ),
                            ),
                          );
                        } else {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => UpdateProjectAssigneesModal(
                              projectId: curProjectId,
                            ),
                          );
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.addUsersTo(
                          curProject.when(
                              data: (project) => project?.name ?? '',
                              error: (e, __) => 'Err: $e',
                              loading: () => '...'))),
                    ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final isSelected = selectedUsers.value.contains(user);
                        return CheckboxListTile(
                          title: Text('${user.firstName} ${user.lastName}'),
                          controlAffinity: ListTileControlAffinity.leading,
                          value: isSelected,
                          onChanged: (bool? value) {
                            if (value != null) {
                              if (value) {
                                selectedUsers.value = [
                                  ...selectedUsers.value,
                                  user
                                ];
                              } else {
                                selectedUsers.value = selectedUsers.value
                                    .where((u) => u != user)
                                    .toList();
                              }
                              onAssigneesChanged(ref, selectedUsers.value);
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
        ),
      ],
    );
  }
}
