import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';

/// Suppression DÉFINITIVE : d'abord les fichiers, ensuite la base.
class TrashService {
  TrashService(this._db);
  final AppDatabase _db;

  Future<void> deletePermanently(String meetingId) async {
    final docs = await getApplicationDocumentsDirectory();
    // Ce dossier contient l'audio (segments) ET les documents exportés.
    final dir = Directory(p.join(docs.path, 'meetings', meetingId));
    if (await dir.exists()) await dir.delete(recursive: true);

    // Copies temporaires créées pour le partage (elles peuvent contenir le texte).
    final tmp = await getTemporaryDirectory();
    final shared = Directory(p.join(tmp.path, 'share'));
    if (await shared.exists()) await shared.delete(recursive: true);

    await _db.purgeMeeting(meetingId);
  }

  /// Retourne le nombre de réunions supprimées. Celles de [skip] sont conservées.
  Future<int> emptyTrash({Set<String> skip = const {}}) async {
    var count = 0;
    for (final m in await _db.getTrash()) {
      if (skip.contains(m.id)) continue;
      await deletePermanently(m.id);
      count++;
    }
    return count;
  }
}