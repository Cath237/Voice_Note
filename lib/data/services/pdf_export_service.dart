import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/utils/formatters.dart';
import 'meeting_document.dart';

/// PDF professionnel : titre, informations, résumé, pagination, en-tête et pied de page.
class PdfExportService {
  pw.Font? _regular;
  pw.Font? _bold;

  Future<void> _loadFonts() async {
    _regular ??= pw.Font.ttf(await rootBundle.load('assets/fonts/DejaVuSans.ttf'));
    _bold ??= pw.Font.ttf(await rootBundle.load('assets/fonts/DejaVuSans-Bold.ttf'));
  }

  Future<Uint8List> build(MeetingDocument d) async {
    await _loadFonts();

    final blue = PdfColor.fromInt(0xFF1565E0);
    final deep = PdfColor.fromInt(0xFF0A2A6B);
    final grey = PdfColor.fromInt(0xFF5B6475);

    final doc = pw.Document(
      title: d.title,
      author: 'VoiceNote',
      theme: pw.ThemeData.withFont(base: _regular!, bold: _bold!),
    );

    pw.Widget heading(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 18, bottom: 8),
      child: pw.Text(text,
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: deep)),
    );

    final body = <pw.Widget>[
      pw.Text(d.title,
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: blue)),
      pw.SizedBox(height: 6),
      pw.Text('${d.dateText} · Durée : ${d.durationText}',
          style: pw.TextStyle(fontSize: 10, color: grey)),
      if (d.category.isNotEmpty)
        pw.Text('Catégorie : ${d.category}', style: pw.TextStyle(fontSize: 10, color: grey)),
      if (d.location.isNotEmpty)
        pw.Text('Lieu : ${d.location}', style: pw.TextStyle(fontSize: 10, color: grey)),
      if (d.participants.isNotEmpty)
        pw.Text('Participants : ${d.participants.join(', ')}',
            style: pw.TextStyle(fontSize: 10, color: grey)),
      pw.Text('Langues : ${d.languages}', style: pw.TextStyle(fontSize: 10, color: grey)),
      if (d.description.isNotEmpty) ...[
        pw.SizedBox(height: 8),
        pw.Text(d.description, style: const pw.TextStyle(fontSize: 11)),
      ],
      pw.SizedBox(height: 10),
      pw.Divider(color: PdfColors.grey300),
    ];

    if (d.hasSummary) {
      body.add(heading('Résumé'));
      for (final line in d.summary!.split('\n')) {
        if (line.trim().isEmpty) continue;
        if (line.startsWith('## ')) {
          body.add(pw.SizedBox(height: 6));
          body.add(pw.Text(line.substring(3),
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: blue)));
          body.add(pw.SizedBox(height: 3));
        } else {
          body.add(pw.Text(line, style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)));
          body.add(pw.SizedBox(height: 3));
        }
      }
    }

    if (d.notes.isNotEmpty) {
      body.add(heading('Notes et marqueurs'));
      for (final n in d.notes) {
        body.add(pw.Text(
          '${formatDuration(n.ms)}   ${n.label}${n.content.isEmpty ? '' : ' : ${n.content}'}',
          style: const pw.TextStyle(fontSize: 11),
        ));
        body.add(pw.SizedBox(height: 4));
      }
    }

    if (d.lines.isNotEmpty) {
      body.add(heading('Transcription'));
      for (final l in d.lines) {
        final meta = [
          if (d.timestamps) formatDuration(l.startMs),
          if (l.speaker != null) l.speaker!,
        ].join(' · ');
        if (meta.isNotEmpty) {
          body.add(pw.Text(meta,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: blue)));
          body.add(pw.SizedBox(height: 2));
        }
        body.add(pw.Text(l.text, style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)));
        body.add(pw.SizedBox(height: 9));
      }
    }

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(42, 46, 42, 46),
      maxPages: 5000, // la valeur par défaut (20 pages) bloquerait une longue réunion
      header: (ctx) => ctx.pageNumber == 1
          ? pw.SizedBox()
          : pw.Container(
        alignment: pw.Alignment.centerRight,
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Text(d.title, style: pw.TextStyle(fontSize: 9, color: grey)),
      ),
      footer: (ctx) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 10),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('VoiceNote', style: pw.TextStyle(fontSize: 9, color: grey)),
            pw.Text('Page ${ctx.pageNumber} / ${ctx.pagesCount}',
                style: pw.TextStyle(fontSize: 9, color: grey)),
          ],
        ),
      ),
      build: (ctx) => body,
    ));

    return doc.save();
  }
}