import 'dart:developer';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';
import 'package:seren_ai_flutter/services/data/budget/widgets/exports/budget_to_pdf_converter.dart';
import 'package:seren_ai_flutter/services/data/budget/widgets/exports/budget_to_csv_converter.dart';

final shareBudgetServiceProvider =
    Provider.autoDispose<ShareBudgetService>(
  (ref) {
    return ShareBudgetService(ref);
  },
);

/// Service for sharing project budget in different formats
class ShareBudgetService {
  final Ref ref;

  ShareBudgetService(this.ref);

  /// Share project budget as PDF
  Future<void> shareBudgetAsPdf({
    required String projectId,
    required List<({String rowNumber, String taskId})> numberedTasks,
    required double projectTotalValue,
    required List<({BudgetItemFieldEnum field, double width})> columns,
    required double projectBdi,
    required NumberFormat currencyFormat,
  }) async {
    try {
      final pdf = BudgetToPdfConverter(ref, projectId);
      await pdf.buildPdf(
        numberedTasks: numberedTasks,
        projectTotalValue: projectTotalValue,
        columns: columns,
        projectBdi: projectBdi,
        currencyFormat: currencyFormat,
      );
      final bytes = await pdf.save();

      // For web: download the file
      _downloadFile(
        bytes,
        'project_budget_$projectId.pdf',
        'application/pdf',
      );

      // For mobile: share the file (but currently budgets are web only)
      /*
      final xFile = XFile.fromData(
        bytes,
        name: 'project_budget_$projectId.pdf',
        mimeType: 'application/pdf',
      );

      await Share.shareXFiles(
        [xFile],
        subject: 'Project Budget',
      );
      */
    } catch (e) {
      log('PDF generation/sharing error: $e');
      rethrow;
    }
  }

  /// Share project budget as CSV
  Future<void> shareBudgetAsCsv({
    required String projectId,
    required List<({String rowNumber, String taskId})> numberedTasks,
    required List<BudgetItemFieldEnum> columns,
    required double projectTotalValue,
    required double projectBdi,
    required NumberFormat currencyFormat,
  }) async {
    try {
      final csvConverter = BudgetToCsvConverter(ref);
      final csvData = await csvConverter.convertBudgetToCsv(
        projectId: projectId,
        numberedTasks: numberedTasks,
        columns: columns,
        projectTotalValue: projectTotalValue,
        projectBdi: projectBdi,
        currencyFormat: currencyFormat,
      );

      // For web: download the file
      _downloadFile(
        Uint8List.fromList(csvData.codeUnits),
        'project_budget_${DateFormat.yMd().add_Hms().format(DateTime.now())}.csv',
        'text/csv',
      );

      // For mobile: share the file (but currently budgets are web only)
      /*
      final xFile = XFile.fromData(
        Uint8List.fromList(csvData.codeUnits),
        name: 'project_budget_$projectId.csv',
        mimeType: 'text/csv',
      );

      await Share.shareXFiles(
        [xFile],
        subject: 'Project Budget',
      );
      */
    } catch (e) {
      log('CSV generation/sharing error: $e');
      rethrow;
    }
  }

  /// Download file for web platform
  void _downloadFile(Uint8List bytes, String fileName, String mimeType) {
    // Create a blob from the bytes
    final blob = html.Blob([bytes], mimeType);

    // Create a URL for the blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create an anchor element
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';

    // Add the anchor to the document body
    html.document.body?.children.add(anchor);

    // Trigger the download
    anchor.click();

    // Clean up
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
