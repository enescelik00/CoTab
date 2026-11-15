import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/models/expense.dart';
import 'package:cotab/models/expense_share.dart';
import 'package:cotab/utils/balance_calculator.dart';

// Small helpers so the tests stay short.
Expense makeExpense(String id, String paidBy, int amount) {
  return Expense(
    id: id,
    groupId: 'group1',
    title: 'Test',
    amount: amount,
    paidBy: paidBy,
    category: 'food',
    expenseDate: 1763100000000,
    splitType: 'equal',
    updatedAt: 1763100000000,
  );
}

ExpenseShare makeShare(String expenseId, String userId, int amount) {
  return ExpenseShare(
    id: ExpenseShare.createId(expenseId, userId),
    groupId: 'group1',
    expenseId: expenseId,
    userId: userId,
    amount: amount,
    updatedAt: 1763100000000,
  );
}

void main() {
  test('Ali pays 300 TL for three people', () {
    final balances = calculateBalances(
      ['ali', 'ayse', 'mehmet'],
      [makeExpense('e1', 'ali', 30000)],
      [
        makeShare('e1', 'ali', 10000),
        makeShare('e1', 'ayse', 10000),
        makeShare('e1', 'mehmet', 10000),
      ],
    );

    expect(balances['ali'], 20000);
    expect(balances['ayse'], -10000);
    expect(balances['mehmet'], -10000);
  });

  test('Two expenses by different people', () {
    // Ali pays 100 TL, Ayşe pays 60 TL, both split between the two.
    final balances = calculateBalances(
      ['ali', 'ayse'],
      [makeExpense('e1', 'ali', 10000), makeExpense('e2', 'ayse', 6000)],
      [
        makeShare('e1', 'ali', 5000),
        makeShare('e1', 'ayse', 5000),
        makeShare('e2', 'ali', 3000),
        makeShare('e2', 'ayse', 3000),
      ],
    );

    // Ali: paid 100, his shares are 50 + 30 = 80, so +20 TL.
    expect(balances['ali'], 2000);
    expect(balances['ayse'], -2000);
  });

  test('A member without expenses has a balance of 0', () {
    final balances = calculateBalances(['ali', 'ayse'], [], []);

    expect(balances['ali'], 0);
    expect(balances['ayse'], 0);
  });

  test('All balances add up to 0', () {
    final balances = calculateBalances(
      ['ali', 'ayse', 'mehmet'],
      [makeExpense('e1', 'mehmet', 10000)],
      [
        makeShare('e1', 'ali', 3333),
        makeShare('e1', 'ayse', 3333),
        makeShare('e1', 'mehmet', 3334),
      ],
    );

    int total = 0;
    for (final balance in balances.values) {
      total += balance;
    }
    expect(total, 0);
  });
}
