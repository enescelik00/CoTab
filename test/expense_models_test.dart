import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/models/expense.dart';
import 'package:cotab/models/expense_item.dart';
import 'package:cotab/models/expense_share.dart';
import 'package:cotab/models/settlement.dart';

void main() {
  test('Expense keeps all fields after toMap and fromMap', () {
    final expense = Expense(
      id: 'expense1',
      groupId: 'group1',
      title: 'Migros',
      amount: 25050,
      paidBy: 'uid123',
      category: 'food',
      expenseDate: 1763100000000,
      splitType: 'equal',
      receiptPath: '/data/receipts/1.jpg',
      updatedAt: 1763200000000,
      deletedAt: 1763300000000,
    );

    final copy = Expense.fromMap(expense.toMap());

    expect(copy.id, 'expense1');
    expect(copy.groupId, 'group1');
    expect(copy.title, 'Migros');
    expect(copy.amount, 25050);
    expect(copy.paidBy, 'uid123');
    expect(copy.category, 'food');
    expect(copy.expenseDate, 1763100000000);
    expect(copy.splitType, 'equal');
    expect(copy.receiptPath, '/data/receipts/1.jpg');
    expect(copy.updatedAt, 1763200000000);
    expect(copy.deletedAt, 1763300000000);
  });

  test('Expense toMap uses the column names of the table', () {
    final expense = Expense(
      id: 'expense1',
      groupId: 'group1',
      title: 'Rent',
      amount: 1500000,
      paidBy: 'uid123',
      category: 'rent',
      expenseDate: 1763100000000,
      splitType: 'exact',
      updatedAt: 1763100000000,
    );

    final map = expense.toMap();

    expect(map['group_id'], 'group1');
    expect(map['paid_by'], 'uid123');
    expect(map['expense_date'], 1763100000000);
    expect(map['split_type'], 'exact');
    expect(map['receipt_path'], isNull);
    expect(map['deleted_at'], isNull);
  });

  test('ExpenseShare keeps all fields after toMap and fromMap', () {
    final share = ExpenseShare(
      id: ExpenseShare.createId('expense1', 'uid123'),
      groupId: 'group1',
      expenseId: 'expense1',
      itemId: 'item1',
      userId: 'uid123',
      amount: 8350,
      updatedAt: 1763200000000,
      deletedAt: 1763300000000,
    );

    final copy = ExpenseShare.fromMap(share.toMap());

    expect(copy.id, 'expense1_uid123');
    expect(copy.groupId, 'group1');
    expect(copy.expenseId, 'expense1');
    expect(copy.itemId, 'item1');
    expect(copy.userId, 'uid123');
    expect(copy.amount, 8350);
    expect(copy.updatedAt, 1763200000000);
    expect(copy.deletedAt, 1763300000000);
  });

  test('ExpenseShare without an item has no item_id', () {
    final share = ExpenseShare(
      id: 'expense1_uid123',
      groupId: 'group1',
      expenseId: 'expense1',
      userId: 'uid123',
      amount: 8350,
      updatedAt: 1763200000000,
    );

    final map = share.toMap();

    expect(map['expense_id'], 'expense1');
    expect(map['user_id'], 'uid123');
    expect(map['item_id'], isNull);
    expect(map['deleted_at'], isNull);
  });

  test('ExpenseItem keeps all fields after toMap and fromMap', () {
    final item = ExpenseItem(
      id: 'item1',
      groupId: 'group1',
      expenseId: 'expense1',
      name: 'Süt 1L',
      amount: 3995,
      updatedAt: 1763200000000,
      deletedAt: 1763300000000,
    );

    final copy = ExpenseItem.fromMap(item.toMap());

    expect(copy.id, 'item1');
    expect(copy.groupId, 'group1');
    expect(copy.expenseId, 'expense1');
    expect(copy.name, 'Süt 1L');
    expect(copy.amount, 3995);
    expect(copy.updatedAt, 1763200000000);
    expect(copy.deletedAt, 1763300000000);
  });

  test('Settlement keeps all fields after toMap and fromMap', () {
    final settlement = Settlement(
      id: 'settlement1',
      groupId: 'group1',
      fromUserId: 'uid123',
      toUserId: 'uid456',
      amount: 12000,
      settledAt: 1763100000000,
      updatedAt: 1763200000000,
      deletedAt: 1763300000000,
    );

    final copy = Settlement.fromMap(settlement.toMap());

    expect(copy.id, 'settlement1');
    expect(copy.groupId, 'group1');
    expect(copy.fromUserId, 'uid123');
    expect(copy.toUserId, 'uid456');
    expect(copy.amount, 12000);
    expect(copy.settledAt, 1763100000000);
    expect(copy.updatedAt, 1763200000000);
    expect(copy.deletedAt, 1763300000000);
  });

  test('Settlement toMap uses the column names of the table', () {
    final settlement = Settlement(
      id: 'settlement1',
      groupId: 'group1',
      fromUserId: 'uid123',
      toUserId: 'uid456',
      amount: 12000,
      settledAt: 1763100000000,
      updatedAt: 1763100000000,
    );

    final map = settlement.toMap();

    expect(map['from_user_id'], 'uid123');
    expect(map['to_user_id'], 'uid456');
    expect(map['settled_at'], 1763100000000);
    expect(map['deleted_at'], isNull);
  });
}
