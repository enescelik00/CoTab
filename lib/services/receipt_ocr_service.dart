import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

String orderReceiptLines(List<({String text, Rect box})> lines) {
  final sorted = [...lines]
    ..sort((a, b) => a.box.center.dy.compareTo(b.box.center.dy));
  final rows = <List<({String text, Rect box})>>[];

  // ML Kit may return text blocks in column order; use image coordinates.
  for (final line in sorted) {
    if (line.text.trim().isEmpty) continue;
    if (rows.isEmpty ||
        (line.box.center.dy - rows.last.first.box.center.dy).abs() >
            rows.last.first.box.height / 2) {
      rows.add([line]);
    } else {
      rows.last.add(line);
    }
  }

  return rows
      .map((row) {
        row.sort((a, b) => a.box.left.compareTo(b.box.left));
        return row.map((line) => line.text.trim()).join('  ');
      })
      .join('\n');
}

Future<String> readReceiptText(String imagePath) async {
  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  try {
    final image = InputImage.fromFilePath(imagePath);
    final result = await recognizer.processImage(image);
    final lines = <({String text, Rect box})>[];
    for (final block in result.blocks) {
      for (final line in block.lines) {
        lines.add((text: line.text, box: line.boundingBox));
      }
    }
    return lines.isEmpty ? result.text : orderReceiptLines(lines);
  } finally {
    await recognizer.close();
  }
}
