import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/utils/string_extension.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_ui_action_request_model.dart';

class UiActionMessageWidget extends ConsumerWidget {
  const UiActionMessageWidget(this._uiActionRequestModel, {super.key});

  final AiUiActionRequestModel _uiActionRequestModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 2), // More pronounced border
        borderRadius: BorderRadius.circular(8), // Optional: rounded corners
      ),
      child: InkWell(
        onTap: () => ref.read(navigationServiceProvider).navigateTo(
              switch (_uiActionRequestModel.uiActionType) {
                AiUIActionRequestType.shiftsPage => AppRoutes.shifts.toString(),
              },
              arguments: _uiActionRequestModel.args,
            ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(_uiActionRequestModel
                        .uiActionType.name.enumToHumanReadable),
                  ),
                  const Icon(Icons.open_in_new),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
