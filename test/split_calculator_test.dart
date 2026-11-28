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
      final shares = splitByPercentage(12345, {
        'ali': 33,
        'ayse': 33,
        'mehmet': 34,
      }, 'mehmet');

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

  group('percentagesFromShares', () {
    test('Gives back the percentages of a split', () {
      final shares = splitByPercentage(20000, {
        'ali': 50,
        'ayse': 30,
        'mehmet': 20,
      }, 'ali');

      expect(percentagesFromShares(20000, shares), {
        'ali': 50,
        'ayse': 30,
        'mehmet': 20,
      });
    });

    test('Works when the payer got the leftover kuruş', () {
      // 33% of 100,01 TL is 33,0033 TL: the payer gets the extra kuruş.
      final shares = splitByPercentage(10001, {
        'ali': 33,
        'ayse': 33,
        'mehmet': 34,
      }, 'ayse');

      expect(percentagesFromShares(10001, shares), {
        'ali': 33,
        'ayse': 33,
        'mehmet': 34,
      });
    });

    test('Rounds a share that is not a whole percent', () {
      // 1/3 of 100 TL is 33,33 %, shown as 33.
      expect(percentagesFromShares(10000, {'ali': 3333}), {'ali': 33});
      // 2/3 is 66,67 %, shown as 67.
      expect(percentagesFromShares(10000, {'ali': 6667}), {'ali': 67});
    });

    test('Editing without changes gives the same shares again', () {
      // Many amounts and percentage sets. For amounts of at least 10 TL the
      // percentages always come back exactly, so saving an edited expense
      // without changes does not move a single kuruş.
      final percentageSets = <Map<String, int>>[
        {'a': 50, 'b': 50},
        {'a': 33, 'b': 33, 'c': 34},
        {'a': 1, 'b': 99},
        {'a': 10, 'b': 20, 'c': 30, 'd': 40},
        {'a': 17, 'b': 17, 'c': 17, 'd': 17, 'e': 16, 'f': 16},
        {'a': 100},
      ];
      for (int amount = 1000; amount <= 60000; amount += 137) {
        for (final percentages in percentageSets) {
          for (final paidBy in ['a', 'b', 'z']) {
            final shares = splitByPercentage(amount, percentages, paidBy);
            final back = percentagesFromShares(amount, shares);
            expect(back, percentages, reason: 'amount $amount, $percentages');
            expect(splitByPercentage(amount, back, paidBy), shares);
          }
        }
      }
    });
  });

  group('splitByItems', () {
    test('Every item is split between the people who had it', () {
      // Süt 40 TL for Ali and Ayşe, Ekmek 10 TL only for Ali.
      final totals = splitByItems([
        ItemSplit(name: 'Süt', amount: 4000, userIds: ['ali', 'ayse']),
        ItemSplit(name: 'Ekmek', amount: 1000, userIds: ['ali']),
      ], 'ayse');

      expect(totals, {'ali': 3000, 'ayse': 2000});
    });

    test('The payer gets the leftover kuruş of every item', () {
      // 10 TL between three people: 3,34 + 3,33 + 3,33, twice.
      final items = [
        ItemSplit(name: 'A', amount: 1000, userIds: ['ali', 'ayse', 'mehmet']),
        ItemSplit(name: 'B', amount: 1000, userIds: ['ali', 'ayse', 'mehmet']),
      ];

      expect(splitByItems(items, 'mehmet'), {
        'ali': 666,
        'ayse': 666,
        'mehmet': 668,
      });
    });

    test('Someone in no item pays nothing', () {
      final totals = splitByItems([
        ItemSplit(name: 'Çay', amount: 2500, userIds: ['ayse']),
      ], 'ali');

      expect(totals, {'ayse': 2500});
    });

    test('The totals always add up to the sum of the items', () {
      final people = ['a', 'b', 'c', 'd'];
      for (int seed = 1; seed <= 200; seed++) {
        // Different items with different people, made from the seed.
        final items = <ItemSplit>[];
        int sum = 0;
        for (int i = 0; i < 1 + seed % 5; i++) {
          final amount = (seed * 37 + i * 101) % 9000 + 1;
          final userIds = <String>[];
          for (int p = 0; p < people.length; p++) {
            if ((seed + i + p) % 3 != 0) {
              userIds.add(people[p]);
            }
          }
          if (userIds.isEmpty) {
            userIds.add('a');
          }
          items.add(ItemSplit(name: 'x', amount: amount, userIds: userIds));
          sum += amount;
        }

        expect(sumOf(splitByItems(items, people[seed % 4])), sum);
      }
    });
  });
}
