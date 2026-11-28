import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/models/expense.dart';
import 'package:cotab/models/expense_share.dart';
import 'package:cotab/utils/balance_calculator.dart';
import 'package:cotab/utils/debt_simplifier.dart';
import 'package:cotab/utils/split_calculator.dart';

// Shortens a payment to 'from->to:amount', so a whole list can be checked
// in one line.
String describe(SuggestedPayment payment) {
  return '${payment.fromUserId}->${payment.toUserId}:${payment.amount}';
}

List<String> describeAll(List<SuggestedPayment> payments) {
  final lines = <String>[];
  for (final payment in payments) {
    lines.add(describe(payment));
  }
  return lines;
}

// Makes every payment and returns the new balances. If the payments are
// right, everybody ends at 0.
Map<String, int> applyPayments(
  Map<String, int> balances,
  List<SuggestedPayment> payments,
) {
  final result = Map<String, int>.from(balances);
  for (final payment in payments) {
    // Paying a debt raises the payer's balance and lowers the receiver's.
    result[payment.fromUserId] = result[payment.fromUserId]! + payment.amount;
    result[payment.toUserId] = result[payment.toUserId]! - payment.amount;
  }
  return result;
}

void main() {
  group('examples', () {
    test('One person paid for two others', () {
      final payments = simplifyDebts({
        'ali': 20000,
        'ayse': -10000,
        'mehmet': -10000,
      });

      expect(describeAll(payments), ['ayse->ali:10000', 'mehmet->ali:10000']);
    });

    test('A chain becomes one payment', () {
      // Ali paid 100 TL for Ayşe, Ayşe paid 100 TL for Mehmet.
      // Ayşe is at 0, so Mehmet pays Ali directly: 1 payment instead of 2.
      final payments = simplifyDebts({
        'ali': 10000,
        'ayse': 0,
        'mehmet': -10000,
      });

      expect(describeAll(payments), ['mehmet->ali:10000']);
    });

    test('The biggest debtor pays the biggest creditor first', () {
      final payments = simplifyDebts({
        'ali': 30000,
        'ayse': 10000,
        'mehmet': -25000,
        'zeynep': -15000,
      });

      expect(describeAll(payments), [
        'mehmet->ali:25000', // Mehmet owes the most, Ali gets the most
        'zeynep->ayse:10000', // now Ayşe (+100) gets more than Ali (+50)
        'zeynep->ali:5000',
      ]);
    });

    test('Odd kuruş from an equal split', () {
      // 100 TL split three ways, Ali paid: his share is 33,34 TL.
      final payments = simplifyDebts({
        'ali': 6666,
        'ayse': -3333,
        'mehmet': -3333,
      });

      expect(describeAll(payments), ['ayse->ali:3333', 'mehmet->ali:3333']);
    });

    test('Everybody settled: no payments', () {
      expect(simplifyDebts({'ali': 0, 'ayse': 0}), isEmpty);
    });

    test('Empty group: no payments', () {
      expect(simplifyDebts({}), isEmpty);
    });

    test('The map of the caller is not changed', () {
      final balances = {'ali': 5000, 'ayse': -5000};

      simplifyDebts(balances);

      expect(balances, {'ali': 5000, 'ayse': -5000});
    });
  });

  group('rules that must hold for every group', () {
    // Different groups, including ones where amounts do not divide evenly.
    final groups = <Map<String, int>>[
      {'a': 20000, 'b': -10000, 'c': -10000},
      {'a': 30000, 'b': 10000, 'c': -25000, 'd': -15000},
      {'a': -1, 'b': -1, 'c': 2},
      {'a': 12345, 'b': -6789, 'c': -5556},
      {'a': 1000, 'b': 2000, 'c': 3000, 'd': -6000},
      {'a': -1000, 'b': -2000, 'c': -3000, 'd': 6000},
      {'a': 4999, 'b': -1250, 'c': 3001, 'd': -2500, 'e': -4250},
      {'a': 100, 'b': -100, 'c': 100, 'd': -100, 'e': 100, 'f': -100},
    ];

    test('After all payments, everybody is at 0', () {
      for (final balances in groups) {
        final after = applyPayments(balances, simplifyDebts(balances));
        for (final userId in after.keys) {
          expect(after[userId], 0, reason: 'group $balances, user $userId');
        }
      }
    });

    test('n people never need more than n - 1 payments', () {
      for (final balances in groups) {
        final payments = simplifyDebts(balances);
        expect(
          payments.length,
          lessThanOrEqualTo(balances.length - 1),
          reason: 'group $balances',
        );
      }
    });

    test('Only people who owe pay, only people who get back receive', () {
      for (final balances in groups) {
        for (final payment in simplifyDebts(balances)) {
          expect(balances[payment.fromUserId]!, lessThan(0));
          expect(balances[payment.toUserId]!, greaterThan(0));
          expect(payment.amount, greaterThan(0));
        }
      }
    });
  });

  test('From expenses to payments', () {
    // Three people in a house:
    // - Ali pays 300 TL rent, split equally.
    // - Ayşe pays 90 TL market, split equally.
    // - Mehmet pays 60 TL internet, only for Ali and Mehmet.
    final members = ['ali', 'ayse', 'mehmet'];
    final expenses = <Expense>[];
    final shares = <ExpenseShare>[];

    void addExpense(String id, String paidBy, int amount, List<String> who) {
      expenses.add(
        Expense(
          id: id,
          groupId: 'group1',
          title: id,
          amount: amount,
          paidBy: paidBy,
          category: 'other',
          expenseDate: 1763100000000,
          splitType: 'equal',
          updatedAt: 1763100000000,
        ),
      );
      final split = splitEqually(amount, who, paidBy);
      for (final userId in split.keys) {
        shares.add(
          ExpenseShare(
            id: ExpenseShare.createId(id, userId),
            groupId: 'group1',
            expenseId: id,
            userId: userId,
            amount: split[userId]!,
            updatedAt: 1763100000000,
          ),
        );
      }
    }

    addExpense('rent', 'ali', 30000, members);
    addExpense('market', 'ayse', 9000, members);
    addExpense('internet', 'mehmet', 6000, ['ali', 'mehmet']);

    final balances = calculateBalances(members, expenses, shares);
    // Ali: paid 300, shares 100 + 30 + 30 = 160 -> +140
    // Ayşe: paid 90, shares 100 + 30 = 130 -> -40
    // Mehmet: paid 60, shares 100 + 30 + 30 = 160 -> -100
    expect(balances, {'ali': 14000, 'ayse': -4000, 'mehmet': -10000});

    final payments = simplifyDebts(balances);
    expect(describeAll(payments), ['mehmet->ali:10000', 'ayse->ali:4000']);
  });
}
