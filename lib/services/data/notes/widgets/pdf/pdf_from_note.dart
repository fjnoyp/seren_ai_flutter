import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:seren_ai_flutter/common/utils/string_extension.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_note_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_attachments_service_provider.dart';

class NoteToPdfConverter extends Document {
  final WidgetRef ref;

  NoteToPdfConverter(this.ref) : super(theme: ThemeData.withFont(
    base: Font.courier(),
    italic: Font.courierOblique(), 
    bold: Font.courierBold(),
    boldItalic: Font.courierBoldOblique(),
  ));

  final pageFormat = PdfPageFormat.a4;

  Future<void> buildPdf() async {
    final joinedNote = ref.watch(curNoteStateProvider).valueOrNull;

    final attachmentWidgets = await _attachmentWidgets(joinedNote!);

    addPage(
      Page(
        pageFormat: pageFormat,
        build: (Context context) {
          return Column(
            children: [
              ..._headerWidgets(joinedNote),
              SizedBox(height: 12.0),
              Divider(),
              SizedBox(height: 12.0),
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _bodyWidgets(joinedNote),
                ),
              ),
              SizedBox(height: 16.0),
              ...attachmentWidgets,
            ],
          );
        },
      ),
    );
  }

  List<Widget> _headerWidgets(JoinedNoteModel joinedNote) {
    return [
      Text(
        joinedNote.note.name,
        style: const TextStyle(fontSize: 28.0),
      ),
      Text(
        joinedNote.project?.name ??
            AppLocalizations.of(ref.context)!.pdfPersonal,
        style: const TextStyle(fontSize: 16.0),
      ),
      SizedBox(height: 16.0),
      Text(
        AppLocalizations.of(ref.context)!.pdfCreatedBy(
          '${joinedNote.authorUser?.firstName} ${joinedNote.authorUser?.lastName}',
          DateFormat.yMMMd(AppLocalizations.of(ref.context)!.localeName)
              .format(joinedNote.note.createdAt!),
        ),
      ),
      SizedBox(height: 16.0),
      Text(
        AppLocalizations.of(ref.context)!.pdfStatus(
            joinedNote.note.status?.toHumanReadable(ref.context) ?? ''),
      ),
    ];
  }

  List<Widget> _bodyWidgets(JoinedNoteModel joinedNote) {
    return [
      Text(
        AppLocalizations.of(ref.context)!.pdfDescription,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      Text(joinedNote.note.description ?? ''),
      SizedBox(height: 16.0),
      Text(
        AppLocalizations.of(ref.context)!.pdfAddress,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      Text(joinedNote.note.address ?? ''),
      SizedBox(height: 16.0),
      Text(
        AppLocalizations.of(ref.context)!.pdfActionRequired,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      Text(joinedNote.note.actionRequired ?? ''),
    ];
  }

  Future<List<Widget>> _attachmentWidgets(
    JoinedNoteModel joinedNote,
  ) async {
    final imageAttachments = <MemoryImage>[];
    final fileAttachments = <UrlLink>[];
    final attachments = ref.watch(noteAttachmentsServiceProvider);

    await Future.wait(
      attachments.map(
        (e) async => switch (e.split('.').last) {
          'png' || 'jpg' || 'jpeg' => imageAttachments.add(
              MemoryImage(
                await ref
                    .read(noteAttachmentsServiceProvider.notifier)
                    .getAttachmentBytes(
                      fileUrl: e,
                      noteId: joinedNote.note.id,
                    ),
              ),
            ),
          _ => fileAttachments.add(
              UrlLink(
                destination: e,
                child: Text(
                  e.getFilePathName(),
                  style: const TextStyle(
                    color: PdfColors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        },
      ),
    );

    return [
      Text(
        AppLocalizations.of(ref.context)!.pdfImageAttachments,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      SizedBox(height: 8.0),
      Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: imageAttachments
            .map((e) => Image(e, width: pageFormat.availableWidth * 0.25))
            .toList(),
      ),
      SizedBox(height: 16.0),
      Text(
        AppLocalizations.of(ref.context)!.pdfOtherAttachments,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      ...fileAttachments,
    ];
  }
}
