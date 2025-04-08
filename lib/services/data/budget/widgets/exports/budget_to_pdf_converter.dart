import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';
import 'package:seren_ai_flutter/services/data/budget/models/budget_item_ref_model.dart';
import 'package:seren_ai_flutter/services/data/budget/models/task_budget_item_model.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/budget_item_refs_repository.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/task_budget_items_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';

class BudgetToPdfConverter extends Document {
  final Ref ref;
  final String projectId;

  BudgetToPdfConverter(this.ref, this.projectId)
      : super(
          theme: ThemeData.base().copyWith(
            defaultTextStyle: const TextStyle(fontSize: 8),
          ),
        );

  static const baseColor = PdfColors.grey300;
  static const baseMargin = 1.0 * PdfPageFormat.cm;

  // Define a custom page format with smaller margins
  final pageFormat = PdfPageFormat.a4.copyWith(
    marginLeft: baseMargin,
    marginRight: baseMargin,
    marginTop: baseMargin,
    marginBottom: baseMargin,
  );

  Future<void> buildPdf({
    required List<({String rowNumber, String taskId})> numberedTasks,
    required double projectTotalValue,
    required List<({BudgetItemFieldEnum field, double width})> columns,
    required double projectBdi,
    required NumberFormat currencyFormat,
  }) async {
    final project =
        await ref.read(projectsRepositoryProvider).getById(projectId);
    if (project == null) throw Exception('Project not found');

    // Calculate total width for proportional scaling
    final totalWidth = columns.fold(0.0, (sum, column) => sum + column.width);

    // Pre-fetch all data needed for the PDF
    final tableContent = await _buildTableContent(
      numberedTasks,
      columns,
      projectTotalValue,
      projectBdi,
      totalWidth,
      currencyFormat,
    );

    // Create a multi-page document with repeating headers
    addPage(
      MultiPage(
        pageFormat: pageFormat,
        header: (Context context) {
          return Column(
            children: [
              _buildHeader(project.name, projectBdi),
              SizedBox(height: 8.0),
              _buildTableHeader(columns, totalWidth),
            ],
          );
        },
        footer: (Context context) {
          return _buildFooter(projectTotalValue, currencyFormat);
        },
        build: (Context context) {
          return [tableContent];
        },
      ),
    );
  }

  Widget _buildHeader(String projectName, double projectBdi) {
    final context =
        ref.read(navigationServiceProvider).navigatorKey.currentContext;
    if (context == null) throw Exception('Context not found');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          projectName,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          'Budget Report - ${DateFormat.yMMMd(AppLocalizations.of(context)!.localeName).format(DateTime.now())}',
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          'BDI: $projectBdi%',
          style: const TextStyle(fontSize: 12),
        ),
        SizedBox(height: 8),
        Divider(),
      ],
    );
  }

  Widget _buildTableHeader(
      List<({BudgetItemFieldEnum field, double width})> columns,
      double totalWidth) {
    final context =
        ref.read(navigationServiceProvider).navigatorKey.currentContext;
    if (context == null) throw Exception('Context not found');

    return Container(
      color: baseColor.shade(0.7),
      child: Row(
        children: columns.map((column) {
          return Container(
            width: pageFormat.availableWidth * (column.width / totalWidth),
            padding: const EdgeInsets.all(4),
            child: Text(
              column.field.toHumanReadable(context),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<Widget> _buildTableContent(
      List<({String rowNumber, String taskId})> numberedTasks,
      List<({BudgetItemFieldEnum field, double width})> columns,
      double projectTotalValue,
      double projectBdi,
      double totalWidth,
      NumberFormat currencyFormat) async {
    final tableContent = <Widget>[];

    for (final task in numberedTasks) {
      // Get task data
      final taskRow = await _buildTaskRow(
        task,
        columns,
        projectTotalValue,
        projectBdi,
        totalWidth,
        currencyFormat,
      );

      // Calculate color based on task depth (similar to the Flutter UI)
      final taskDepth = task.rowNumber.split('.').length;
      final taskColor =
          baseColor.shade(0.6 - (taskDepth * 0.1).clamp(0.0, 0.5));

      tableContent.add(
        Container(
          color: taskColor,
          child: taskRow,
        ),
      );

      // Add divider after each task row
      tableContent.add(Divider(height: 1));

      // Get budget items for this task
      final budgetItems = await ref
          .read(taskBudgetItemsRepositoryProvider)
          .getTaskBudgets(taskId: task.taskId);

      // Add each budget item with its own divider
      for (final item in budgetItems) {
        final itemRow = await _buildBudgetItemRow(item, task.rowNumber, columns,
            projectTotalValue, projectBdi, totalWidth, currencyFormat);

        tableContent.add(
          Container(
            color: PdfColors.white,
            child: itemRow,
          ),
        );

        // Add divider after each budget item row
        tableContent.add(Divider(height: 1));
      }
    }

    return Column(children: tableContent);
  }

  Future<Widget> _buildTaskRow(
      ({String rowNumber, String taskId}) task,
      List<({BudgetItemFieldEnum field, double width})> columns,
      double projectTotalValue,
      double projectBdi,
      double totalWidth,
      NumberFormat currencyFormat) async {
    // Fetch all field values for this task
    final values = await Future.wait(columns.map((column) async {
      return await _getTaskFieldValue(
        taskId: task.taskId,
        taskNumber: task.rowNumber,
        field: column.field,
        projectTotalValue: projectTotalValue,
        projectBdi: projectBdi,
        currencyFormat: currencyFormat,
      );
    }));

    return Row(
      children: List.generate(columns.length, (index) {
        return Container(
          width:
              pageFormat.availableWidth * (columns[index].width / totalWidth),
          padding: const EdgeInsets.all(4),
          child: Text(
            values[index],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  Future<Widget> _buildBudgetItemRow(
      TaskBudgetItemModel item,
      String itemNumberPrefix,
      List<({BudgetItemFieldEnum field, double width})> columns,
      double projectTotalValue,
      double projectBdi,
      double totalWidth,
      NumberFormat currencyFormat) async {
    final values = await Future.wait(columns.map((column) async {
      return await _getBudgetItemFieldValue(
        item: item,
        field: column.field,
        itemNumberPrefix: itemNumberPrefix,
        projectTotalValue: projectTotalValue,
        projectBdi: projectBdi,
        currencyFormat: currencyFormat,
      );
    }));

    return Row(
      children: List.generate(columns.length, (index) {
        return Container(
          width:
              pageFormat.availableWidth * (columns[index].width / totalWidth),
          padding: const EdgeInsets.all(4),
          child: Text(values[index]),
        );
      }),
    );
  }

  Widget _buildFooter(double projectTotalValue, NumberFormat currencyFormat) {
    return Column(
      children: [
        Divider(thickness: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Total Budget: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              currencyFormat.format(projectTotalValue),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Future<String> _getTaskFieldValue({
    required String taskId,
    required String taskNumber,
    required BudgetItemFieldEnum field,
    required double projectTotalValue,
    required double projectBdi,
    required NumberFormat currencyFormat,
  }) async {
    final task = await ref.read(tasksRepositoryProvider).getById(taskId);
    if (task == null) return 'Task not found';

    final taskBudgetItems = await ref
        .read(taskBudgetItemsRepositoryProvider)
        .getTaskBudgets(taskId: taskId);

    final taskTotalValue =
        taskBudgetItems.fold(0.0, (sum, item) => sum + item.totalValue);

    return switch (field) {
      BudgetItemFieldEnum.itemNumber => taskNumber,
      BudgetItemFieldEnum.name => task.name,
      BudgetItemFieldEnum.totalValue => currencyFormat.format(taskTotalValue),
      BudgetItemFieldEnum.totalValueWithBdi =>
        currencyFormat.format(taskTotalValue * (1 + projectBdi)),
      BudgetItemFieldEnum.weight =>
        ((taskTotalValue / projectTotalValue) * 100).toStringAsFixed(2),
      _ => '',
    };
  }

  Future<String> _getBudgetItemFieldValue({
    required TaskBudgetItemModel item,
    required BudgetItemFieldEnum field,
    required String itemNumberPrefix,
    required double projectTotalValue,
    required double projectBdi,
    required NumberFormat currencyFormat,
  }) async {
    BudgetItemRefModel? matchedItemRef;

    if (item.budgetItemRefId != null) {
      matchedItemRef = await ref
          .read(budgetItemRefsRepositoryProvider)
          .getById(item.budgetItemRefId!);
    }

    final refModel = matchedItemRef ?? BudgetItemRefModel.empty();

    return switch (field) {
      BudgetItemFieldEnum.itemNumber => '$itemNumberPrefix.${item.itemNumber}',
      BudgetItemFieldEnum.type => refModel.type,
      BudgetItemFieldEnum.source => refModel.source,
      BudgetItemFieldEnum.code => refModel.code,
      BudgetItemFieldEnum.name => refModel.name,
      BudgetItemFieldEnum.amount => item.amount.toString(),
      BudgetItemFieldEnum.measureUnit => refModel.measureUnit,
      BudgetItemFieldEnum.unitValue => currencyFormat.format(item.unitValue),
      BudgetItemFieldEnum.unitValueWithBdi =>
        currencyFormat.format(item.unitValue * (1 + projectBdi)),
      BudgetItemFieldEnum.totalValue => currencyFormat.format(item.totalValue),
      BudgetItemFieldEnum.totalValueWithBdi =>
        currencyFormat.format(item.totalValue * (1 + projectBdi)),
      BudgetItemFieldEnum.weight =>
        ((item.totalValue / projectTotalValue) * 100).toStringAsFixed(2),
    };
  }
}
