import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/services/receipt_ocr_service.dart';

void main() {
  test('OCR lines follow receipt rows instead of block order', () {
    final lines = [
      (text: '*410,00', box: const Rect.fromLTWH(200, 100, 70, 20)),
      (text: 'TOPLAM', box: const Rect.fromLTWH(10, 100, 80, 20)),
      (text: '15-01-2024', box: const Rect.fromLTWH(10, 20, 100, 20)),
      (text: '13:20', box: const Rect.fromLTWH(220, 21, 50, 20)),
      (text: 'KDV', box: const Rect.fromLTWH(10, 70, 40, 20)),
      (text: '*68,34', box: const Rect.fromLTWH(210, 71, 60, 20)),
    ];

    expect(
      orderReceiptLines(lines),
      '15-01-2024  13:20\nKDV  *68,34\nTOPLAM  *410,00',
    );
  });

  test('Empty OCR lines are skipped', () {
    final lines = [
      (text: '  ', box: const Rect.fromLTWH(0, 0, 20, 20)),
      (text: ' MOTORİN ', box: const Rect.fromLTWH(0, 30, 80, 20)),
    ];

    expect(orderReceiptLines(lines), 'MOTORİN');
  });
}
