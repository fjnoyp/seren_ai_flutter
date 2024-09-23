import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_folder_provider.dart';

class NoteFolderNameField extends BaseNameField {
  NoteFolderNameField({
    super.key,
    required super.enabled,
  }) : super(
          nameProvider: curNoteFolderProvider.select((state) => state.name),
          updateName: (ref, name) => 
              ref.read(curNoteFolderProvider.notifier).updateNoteFolderName(name),
        );
}

class NoteFolderDescriptionField extends BaseTextBlockEditSelectionField {
  NoteFolderDescriptionField({
    super.key,
    required super.enabled,
  }) : super(
          descriptionProvider: curNoteFolderProvider.select((state) => state.description),
          updateDescription: (ref, description) => 
              ref.read(curNoteFolderProvider.notifier).updateDescription(description),
        );
}
