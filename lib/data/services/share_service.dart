import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareItem {
  final String path; // fichier réel sur le téléphone
  final String name; // nom vu par le destinataire
  const ShareItem(this.path, this.name);
}

/// Partage via le menu natif d'Android : WhatsApp, Gmail, Drive, Bluetooth...
/// Aucune API privée n'est utilisée.
class ShareService {
  Future<void> shareFiles(List<ShareItem> items, {String? subject, String? text}) async {
    // On partage des COPIES dans le dossier temporaire : les originaux restent intacts.
    final tmp = await getTemporaryDirectory();
    final dir = Directory(p.join(tmp.path, 'share'));
    await dir.create(recursive: true);

    final files = <XFile>[];
    for (final item in items) {
      final copy = await File(item.path).copy(p.join(dir.path, item.name));
      files.add(XFile(copy.path, mimeType: _mime(item.name)));
    }
    await Share.shareXFiles(files, subject: subject, text: text);
  }

  String _mime(String name) {
    final ext = p.extension(name).toLowerCase();
    return switch (ext) {
      '.docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      '.pdf' => 'application/pdf',
      '.txt' => 'text/plain',
      '.m4a' => 'audio/mp4',
      _ => 'application/octet-stream',
    };
  }
}