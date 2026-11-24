import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Aperçu du PDF avec les boutons Imprimer et Partager d'Android.
class PdfPreviewScreen extends StatelessWidget {
  final Uint8List bytes;
  final String fileName;
  const PdfPreviewScreen({super.key, required this.bytes, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aperçu du PDF')),
      body: PdfPreview(
        build: (_) async => bytes,
        pdfFileName: fileName,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}