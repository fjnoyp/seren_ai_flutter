import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_listener_db_notifier.dart';

final projectsListenerProvider = NotifierProvider.family<
        BaseListenerDbNotifier<ProjectModel>,
        List<ProjectModel>,
        BaseListenerDbParams<ProjectModel>>(
    BaseListenerDbNotifier<ProjectModel>.new);
