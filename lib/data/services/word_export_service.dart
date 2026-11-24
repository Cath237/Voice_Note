import 'dart:convert';

import 'package:archive/archive.dart';

import '../../core/utils/formatters.dart';
import 'meeting_document.dart';

/// Fabrique un vrai fichier .docx (Office Open XML) sans dépendance native.
class WordExportService {
  String _esc(String s) => s
      .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '') // caractères interdits en XML
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  String _run(String text, {bool bold = false, int? size, String? color}) =>
      '<w:r><w:rPr>'
          '<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>'
          '${bold ? '<w:b/>' : ''}'
          '${color != null ? '<w:color w:val="$color"/>' : ''}'
          '${size != null ? '<w:sz w:val="$size"/>' : ''}'
          '</w:rPr><w:t xml:space="preserve">${_esc(text)}</w:t></w:r>';

  String _para(String run, {int after = 100, bool keepNext = false}) =>
      '<w:p><w:pPr>${keepNext ? '<w:keepNext/>' : ''}'
          '<w:spacing w:after="$after"/></w:pPr>$run</w:p>';

  String _heading(String text) =>
      _para(_run(text, bold: true, size: 30, color: '0A2A6B'), after: 120, keepNext: true);

  List<int> build(MeetingDocument d) {
    final b = StringBuffer();

    b.write(_para(_run(d.title, bold: true, size: 44, color: '1565E0'), after: 80));
    b.write(_para(_run('${d.dateText} · Durée : ${d.durationText}', color: '5B6475')));
    if (d.category.isNotEmpty) b.write(_para(_run('Catégorie : ${d.category}')));
    if (d.location.isNotEmpty) b.write(_para(_run('Lieu : ${d.location}')));
    if (d.participants.isNotEmpty) {
      b.write(_para(_run('Participants : ${d.participants.join(', ')}')));
    }
    b.write(_para(_run('Langues : ${d.languages}'), after: 200));
    if (d.description.isNotEmpty) b.write(_para(_run(d.description), after: 200));

    if (d.hasSummary) {
      b.write(_heading('Résumé'));
      for (final line in d.summary!.split('\n')) {
        if (line.trim().isEmpty) continue;
        if (line.startsWith('## ')) {
          b.write(_para(_run(line.substring(3), bold: true, size: 24, color: '1565E0'),
              after: 60, keepNext: true));
        } else {
          b.write(_para(_run(line)));
        }
      }
    }

    if (d.notes.isNotEmpty) {
      b.write(_heading('Notes et marqueurs'));
      for (final n in d.notes) {
        b.write(_para(
          _run('${formatDuration(n.ms)}  ', bold: true, color: '1565E0') +
              _run('${n.label}${n.content.isEmpty ? '' : ' : ${n.content}'}'),
        ));
      }
    }

    if (d.lines.isNotEmpty) {
      b.write(_heading('Transcription'));
      for (final l in d.lines) {
        final meta = [
          if (d.timestamps) formatDuration(l.startMs),
          if (l.speaker != null) l.speaker!,
        ].join(' · ');
        if (meta.isNotEmpty) {
          b.write(_para(_run(meta, bold: true, size: 20, color: '0A2A6B'),
              after: 20, keepNext: true));
        }
        b.write(_para(_run(l.text), after: 140));
      }
    }

    const ns = 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"';
    final document = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:document $ns><w:body>${b.toString()}'
        '<w:sectPr><w:pgSz w:w="11906" w:h="16838"/>'
        '<w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134" '
        'w:header="708" w:footer="708" w:gutter="0"/></w:sectPr>'
        '</w:body></w:document>';

    final archive = Archive()
      ..addFile(_file(
          '[Content_Types].xml',
          '<?xml version="1.0" encoding="UTF-8"?>'
              '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
              '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
              '<Default Extension="xml" ContentType="application/xml"/>'
              '<Override PartName="/word/document.xml" '
              'ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
              '</Types>'))
      ..addFile(_file(
          '_rels/.rels',
          '<?xml version="1.0" encoding="UTF-8"?>'
              '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
              '<Relationship Id="rId1" '
              'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" '
              'Target="word/document.xml"/></Relationships>'))
      ..addFile(_file('word/document.xml', document));

    return ZipEncoder().encode(archive)!;
  }

  ArchiveFile _file(String name, String content) {
    final data = utf8.encode(content);
    return ArchiveFile(name, data.length, data);
  }
}