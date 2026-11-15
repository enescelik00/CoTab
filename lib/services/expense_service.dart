import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';
import '../models/expense_share.dart';
import 'database_helper.dart';
import 'sync_service.dart';

// Adding, reading and deleting expenses.
// Everything is saved with SyncService.saveRow, so it works offline and
// reaches the other members when there is internet.
// Lists are always read from SQLite.
class ExpenseService {
  // Saves a new expense and the share of every person.
  // shares: user id -> share amount in kuruş (from split_calculator.dart).
  static Future<Expense> addExpense({
    required String groupId,
    required String title,
    required int amount,
    required String paidBy,
    required String category,
    required int expenseDate,
    required String splitType,
    required Map<String, int> shares,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Firestore can create a new id without internet.
    final expense = Expense(
      id: FirebaseFirestore.instance.collection('expenses').doc().id,
      groupId: groupId,
      title: title,
      amount: amount,
      paidBy: paidBy,
      category: category,
      expenseDate: expenseDate,
      splitType: splitType,
      updatedAt: now,
    );
    await SyncService.saveRow('expenses', expense.toMap());

    for (final userId in shares.keys) {
      final share = ExpenseShare(
        id: ExpenseShare.createId(expense.id, userId),
        groupId: groupId,
        expenseId: expense.id,
        userId: userId,
        amount: shares[userId]!,
        updatedAt: now,
      );
      await SyncService.saveRow('expense_shares', share.toMap());
    }

    return expense;
  }

  // The expenses of a group, newest first.
  static Future<List<Expense>> getExpenses(String groupId) async {
    final db = await DatabaseHelper.getDatabase();
    final rows = await db.query(
      'expenses',
      where: 'group_id = ? AND deleted_at IS NULL',
      whereArgs: [groupId],
      orderBy: 'expense_date DESC',
    );

    final expenses = <Expense>[];
    for (final row in rows) {
      expenses.add(Expense.fromMap(row));
    }
    return expenses;
  }

  // The shares of all active expenses of a group (for the balances).
  static Future<List<ExpenseShare>> getShares(String groupId) async {
    final db = await DatabaseHelper.getDatabase();
    final rows = await db.rawQuery(
      '''
      SELECT expense_shares.* FROM expense_shares
      JOIN expenses ON expenses.id = expense_shares.expense_id
      WHERE expense_shares.group_id = ?
        AND expense_shares.deleted_at IS NULL
        AND expenses.deleted_at IS NULL
      ''',
      [groupId],
    );

    final shares = <ExpenseShare>[];
    for (final row in rows) {
      shares.add(ExpenseShare.fromMap(row));
    }
    return shares;
  }

  // Soft-deletes an expense and its shares: deleted_at is set, nothing is
  // really removed, so the deletion reaches the other phones too.
  static Future<void> deleteExpense(Expense expense) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final expenseRow = expense.toMap();
    expenseRow['deleted_at'] = now;
    expenseRow['updated_at'] = now;
    await SyncService.saveRow('expenses', expenseRow);

    final db = await DatabaseHelper.getDatabase();
    final shareRows = await db.query(
      'expense_shares',
      where: 'expense_id = ? AND deleted_at IS NULL',
      whereArgs: [expense.id],
    );
    for (final row in shareRows) {
      // Rows from sqflite cannot be changed, so we change a copy.
      final shareRow = Map<String, Object?>.from(row);
      shareRow['deleted_at'] = now;
      shareRow['updated_at'] = now;
      await SyncService.saveRow('expense_shares', shareRow);
    }
  }
}
