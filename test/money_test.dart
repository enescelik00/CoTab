import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/utils/money.dart';

void main() {
  group('parseMoney', () {
    test('Whole lira', () {
      expect(parseMoney('250'), 25000);
    });

    test('Comma and dot both work', () {
      expect(parseMoney('250,50'), 25050);
      expect(parseMoney('250.50'), 25050);
    });

    test('One digit after the comma means tens of kuruş', () {
      expect(parseMoney('250,5'), 25050);
    });

    test('Less than one lira and spaces around', () {
      expect(parseMoney('0,99'), 99);
      expect(parseMoney('  12,30 '), 1230);
    });

    test('Wrong input gives null', () {
      expect(parseMoney(''), isNull);
      expect(parseMoney('abc'), isNull);
      expect(parseMoney('12,345'), isNull);
      expect(parseMoney('1.250,50'), isNull);
      expect(parseMoney('-5'), isNull);
      expect(parseMoney('250,'), isNull);
    });
  });

  group('formatMoney', () {
    test('Kuruş are always two digits', () {
      expect(formatMoney(25050), '250,50 ₺');
      expect(formatMoney(1205), '12,05 ₺');
      expect(formatMoney(0), '0,00 ₺');
    });

    test('Thousands get a dot', () {
      expect(formatMoney(125050), '1.250,50 ₺');
      expect(formatMoney(123456789), '1.234.567,89 ₺');
    });

    test('Negative amounts get a minus sign', () {
      expect(formatMoney(-2000), '-20,00 ₺');
    });
  });
}
