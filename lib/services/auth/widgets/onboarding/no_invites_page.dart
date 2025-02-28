import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/auth/widgets/onboarding/go_to_org_button.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/invite_model.dart';
import 'package:seren_ai_flutter/services/data/users/providers/cur_user_invites_notifier_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoInvitesPage extends HookConsumerWidget {
  const NoInvitesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = useState(0);
    final isNewCompany = useState(true);

    // Form controllers
    final orgNameController = useTextEditingController();
    final orgAddressController = useTextEditingController();
    final projectNameController = useTextEditingController();
    final projectDescriptionController = useTextEditingController();
    final projectAddressController = useTextEditingController();

    // Form keys for validation
    final orgFormKey = useMemoized(() => GlobalKey<FormState>());
    final projectFormKey = useMemoized(() => GlobalKey<FormState>());

    final isCreatingOrg = useState(false);
    final isCreatingProject = useState(false);

    // Cleanup controllers on dispose
    useEffect(() {
      return () {
        orgNameController.dispose();
        orgAddressController.dispose();
        projectNameController.dispose();
        projectDescriptionController.dispose();
        projectAddressController.dispose();
      };
    }, []);

    final user = ref.watch(curUserProvider).value;
    final userEmail = user?.email ?? '';
    final curUserInvites = ref.watch(curUserInvitesNotifierProvider);

    // Create organization method
    Future<void> createOrganization() async {
      if (orgFormKey.currentState?.validate() ?? false) {
        isCreatingOrg.value = true;

        try {
          final orgName = orgNameController.text;
          final orgAddress = orgAddressController.text;
          final userId = user?.id ?? '';

          // Call RPC function instead of direct insertions
          final response = await Supabase.instance.client.rpc(
            'create_organization_with_admin',
            params: {
              'org_name': orgName,
              'org_address': orgAddress,
              'user_id': userId,
            },
          );

          // Extract the org_id from the response
          final orgId = response['org_id'] as String;

          if (orgId.isEmpty) throw Exception('No organization ID returned');

          ref
              .read(curSelectedOrgIdNotifierProvider.notifier)
              .setDesiredOrgId(orgId);

          isCreatingOrg.value = false;
          currentStep.value = 2;
        } catch (e) {
          isCreatingOrg.value = false;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to create organization: ${e.toString()}')),
          );
        }
      }
    }

    // Create project method
    Future<void> createProject() async {
      if (projectFormKey.currentState?.validate() ?? false) {
        isCreatingProject.value = true;

        try {
          final orgId = ref.read(curSelectedOrgIdNotifierProvider);
          // This should never happen, since we set the orgId in the previous step
          if (orgId == null) throw Exception('No organization selected');

          log(userEmail);

          final newProject = ProjectModel(
            name: projectNameController.text,
            description: projectDescriptionController.text,
            address: projectAddressController.text,
            parentOrgId: orgId,
          );

          await ref.read(projectsRepositoryProvider).insertItem(newProject);

          isCreatingProject.value = false;
          currentStep.value = 3;
        } catch (e) {
          isCreatingProject.value = false;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to create project: ${e.toString()}')),
          );
        }
      }
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (currentStep.value == 0)
                  curUserInvites.isEmpty
                      ? _InitialStep(
                          userEmail: userEmail,
                          isNewCompany: isNewCompany.value,
                          onNewCompanyChanged: (value) {
                            isNewCompany.value = value;
                          },
                          onContinue: () => currentStep.value = 1,
                        )
                      : Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: curUserInvites
                              .where((invite) =>
                                  invite.status != InviteStatus.declined)
                              .map((invite) => GoToOrgButton(invite))
                              .toList(),
                        ),
                if (currentStep.value == 1)
                  _OrgCreationStep(
                    isNewCompany: isNewCompany.value,
                    orgFormKey: orgFormKey,
                    orgNameController: orgNameController,
                    orgLocationController: orgAddressController,
                    isCreatingOrg: isCreatingOrg.value,
                    onBack: () => currentStep.value = 0,
                    onCreateOrg: createOrganization,
                  ),
                if (currentStep.value == 2)
                  _ProjectCreationStep(
                    projectFormKey: projectFormKey,
                    projectNameController: projectNameController,
                    projectDescriptionController: projectDescriptionController,
                    projectAddressController: projectAddressController,
                    isCreatingProject: isCreatingProject.value,
                    onBack: () => currentStep.value = 1,
                    onCreateProject: createProject,
                  ),
                if (currentStep.value == 3)
                  _CompletionStep(
                    orgName: orgNameController.text,
                    projectName: projectNameController.text,
                    onGoToDashboard: () {
                      ref.read(navigationServiceProvider).navigateTo(
                            AppRoutes.home.name,
                            clearStack: true,
                          );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InitialStep extends HookConsumerWidget {
  const _InitialStep({
    required this.userEmail,
    required this.isNewCompany,
    required this.onNewCompanyChanged,
    required this.onContinue,
  });

  final String userEmail;
  final bool isNewCompany;
  final ValueChanged<bool> onNewCompanyChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        SvgPicture.asset(
          'assets/images/seren_logo.svg',
          width: 100,
          height: 100,
        ),
        Text(
          l10n.welcomeToSerenAi,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        CheckboxListTile(
          title: Text(
            l10n.newCompanyCreateOrg,
            style: const TextStyle(fontSize: 16),
          ),
          value: isNewCompany,
          onChanged: (value) {
            onNewCompanyChanged(value ?? false);
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 32),
        if (isNewCompany)
          FilledButton(
            onPressed: onContinue,
            child: Text(l10n.createMyOrganization),
          )
        else
          Column(
            children: [
              Text(
                l10n.workerWithoutInvite,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.askForInviteToEmail(userEmail),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.inviteWillBeShown,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
      ],
    );
  }
}

class _OrgCreationStep extends HookConsumerWidget {
  const _OrgCreationStep({
    required this.isNewCompany,
    required this.orgFormKey,
    required this.orgNameController,
    required this.orgLocationController,
    required this.isCreatingOrg,
    required this.onBack,
    required this.onCreateOrg,
  });

  final bool isNewCompany;
  final GlobalKey<FormState> orgFormKey;
  final TextEditingController orgNameController;
  final TextEditingController orgLocationController;
  final bool isCreatingOrg;
  final VoidCallback onBack;
  final Future<void> Function() onCreateOrg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: orgFormKey,
      child: Column(
        children: [
          Text(
            l10n.createYourOrganization,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: orgNameController,
            decoration: InputDecoration(
              labelText: l10n.organizationName,
              hintText: l10n.enterCompanyName,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.pleaseEnterOrgName;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: orgLocationController,
            decoration: InputDecoration(
              labelText: l10n.locationOptional,
              hintText: l10n.enterOrgLocation,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: onBack,
                child: Text(l10n.back),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: isCreatingOrg ? null : onCreateOrg,
                child: isCreatingOrg
                    ? const CircularProgressIndicator()
                    : Text(l10n.continue_),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectCreationStep extends HookConsumerWidget {
  const _ProjectCreationStep({
    required this.projectFormKey,
    required this.projectNameController,
    required this.projectDescriptionController,
    required this.projectAddressController,
    required this.isCreatingProject,
    required this.onBack,
    required this.onCreateProject,
  });

  final GlobalKey<FormState> projectFormKey;
  final TextEditingController projectNameController;
  final TextEditingController projectDescriptionController;
  final TextEditingController projectAddressController;
  final bool isCreatingProject;
  final VoidCallback onBack;
  final Future<void> Function() onCreateProject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: projectFormKey,
      child: Column(
        children: [
          Text(
            l10n.createYourFirstProject,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: projectNameController,
            decoration: InputDecoration(
              labelText: l10n.projectName,
              hintText: l10n.enterFirstProjectName,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.pleaseEnterProjectName;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: projectDescriptionController,
            decoration: InputDecoration(
              labelText: l10n.description,
              hintText: l10n.enterProjectDescription,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: projectAddressController,
            decoration: InputDecoration(
              labelText: l10n.locationOptional,
              hintText: l10n.enterProjectLocation,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: onBack,
                child: Text(l10n.back),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: isCreatingProject ? null : onCreateProject,
                child: isCreatingProject
                    ? const CircularProgressIndicator()
                    : Text(l10n.createProject),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletionStep extends HookConsumerWidget {
  const _CompletionStep({
    required this.orgName,
    required this.projectName,
    required this.onGoToDashboard,
  });

  final String orgName;
  final String projectName;
  final VoidCallback onGoToDashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 64,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.congratulations,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.orgAndProjectCreated(orgName, projectName),
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.inviteTeamMembersInstructions,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: onGoToDashboard,
          child: Text(l10n.goToDashboard),
        ),
      ],
    );
  }
}
