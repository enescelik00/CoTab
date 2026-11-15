import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/utils/split_calculator.dart';

void main() {
  group('splitEqually', () {
    test('100 TL between 3 people: the payer gets the extra kuruş', () {
      final shares = splitEqually(10000, ['ali', 'ayse', 'mehmet'], 'ali');

      expect(shares['ali'], 3334);
      expect(shares['ayse'], 3333);
      expect(shares['mehmet'], 3333);
      expect(sumOf(shares), 10000);
    });

    test('An amount that divides evenly has no leftover', () {
      final shares = splitEqually(9000, ['ali', 'ayse', 'mehmet'], 'ayse');

      expect(shares['ali'], 3000);
      expect(shares['ayse'], 3000);
      expect(shares['mehmet'], 3000);
    });

    test('If the payer is not in the split, the first person gets it', () {
      final shares = splitEqually(1001, ['ayse', 'mehmet'], 'ali');

      expect(shares['ayse'], 501);
      expect(shares['mehmet'], 500);
      expect(shares.containsKey('ali'), isFalse);
    });

    test('One person pays everything', () {
      final shares = splitEqually(4599, ['ali'], 'ali');

      expect(shares['ali'], 4599);
    });
  });

  group('splitByPercentage', () {
    test('50% and 50%', () {
      final shares = splitByPercentage(20000, {'ali': 50, 'ayse': 50}, 'ali');

      expect(shares['ali'], 10000);
      expect(shares['ayse'], 10000);
    });

    test('The payer gets the leftover kuruş', () {
      // 10.01 TL: 50% is 500.5 kuruş, so 1 kuruş is left over.
      final shares = splitByPercentage(1001, {'ali': 50, 'ayse': 50}, 'ayse');

      expect(shares['ali'], 500);
      expect(shares['ayse'], 501);
      expect(sumOf(shares), 1001);
    });

    test('Shares always add up to the total', () {
      final shares = splitByPercentage(
        12345,
        {'ali': 33, 'ayse': 33, 'mehmet': 34},
        'mehmet',
      );

      expect(sumOf(shares), 12345);
    });
  });

  group('checks', () {
    test('percentagesAddUpTo100', () {
      expect(percentagesAddUpTo100({'ali': 60, 'ayse': 40}), isTrue);
      expect(percentagesAddUpTo100({'ali': 60, 'ayse': 30}), isFalse);
    });

    test('sharesMatchAmount', () {
      expect(sharesMatchAmount(10000, {'ali': 7000, 'ayse': 3000}), isTrue);
      expect(sharesMatchAmount(10000, {'ali': 7000, 'ayse': 2999}), isFalse);
    });
  });
}
