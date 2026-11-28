import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';
import '../models/expense_item.dart';
import '../models/expense_share.dart';
import '../utils/split_calculator.dart';
import 'database_helper.dart';
import 'sync_service.dart';

// Adding, editing, reading and deleting expenses.
// Everything is saved with SyncService.saveRow, so it works offline and
// reaches the other members when there is internet.
// Lists are always read from SQLite.
//
// An expense is split in one of two ways:
// - shares: user id -> share amount in kuruş (equal, percentage and exact
//   split, from split_calculator.dart). One share row per person.
// - items: the receipt items and who had each of them (item split). One
//   expense_items row per item and one share row per item and person.
// For an item split, pass the items and an empty shares map.
class ExpenseService {
  // Saves a new expense with its shares or items.
  static Future<Expense> addExpense({
    required String groupId,
    required String title,
    required int amount,
    required String paidBy,
    required String category,
    required int expenseDate,
    required String splitType,
    required Map<String, int> shares,
    List<ItemSplit> items = const [],
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final expense = Expense(
      id: _newId('expenses'),
      groupId: groupId,
      title: title,
      amount: amount,
      paidBy: paidBy,
      category: category,
      expenseDate: expenseDate,
      splitType: splitType,
      updatedAt: now,
    );
    await _saveExpense(expense, shares, items);
    return expense;
  }

  // Saves the changed fields of an existing expense and its new shares or
  // items. The id, the group and the receipt image stay the same.
  static Future<Expense> updateExpense(
    Expense oldExpense, {
    required String title,
    required int amount,
    required String paidBy,
    required String category,
    required int expenseDate,
    required String splitType,
    required Map<String, int> shares,
    List<ItemSplit> items = const [],
  }) async {
    final expense = Expense(
      id: oldExpense.id,
      groupId: oldExpense.groupId,
      title: title,
      amount: amount,
      paidBy: paidBy,
      category: category,
      expenseDate: expenseDate,
      splitType: splitType,
      receiptPath: oldExpense.receiptPath,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _saveExpense(expense, shares, items);
    return expense;
  }

  // Firestore can create a new id without internet.
  static String _newId(String collection) {
    return FirebaseFirestore.instance.collection(collection).doc().id;
  }

  // Used by addExpense and updateExpense: saves the expense row, then its
  // shares (and items). Old shares and items that are not part of the new
  // split are soft-deleted, otherwise they would still count in the
  // balances (for example a person taken out of the split, or a removed
  // receipt item).
  static Future<void> _saveExpense(
    Expense expense,
    Map<String, int> shares,
    List<ItemSplit> items,
  ) async {
    final now = expense.updatedAt;
    await SyncService.saveRow('expenses', expense.toMap());

    final newShareIds = <String>{};
    final newItemIds = <String>{};

    // Equal, percentage or exact split: one share per person.
    for (final userId in shares.keys) {
      final share = ExpenseShare(
        id: ExpenseShare.createId(expense.id, userId),
        groupId: expense.groupId,
        expenseId: expense.id,
        userId: userId,
        amount: shares[userId]!,
        updatedAt: now,
      );
      await SyncService.saveRow('expense_shares', share.toMap());
      newShareIds.add(share.id);
    }

    // Item split: every item is saved and split equally between the people
    // who had it (the payer gets the leftover kuruş of each item).
    for (final itemSplit in items) {
      final item = ExpenseItem(
        id: itemSplit.id ?? _newId('expense_items'),
        groupId: expense.groupId,
        expenseId: expense.id,
        name: itemSplit.name,
        amount: itemSplit.amount,
        updatedAt: now,
      );
      await SyncService.saveRow('expense_items', item.toMap());
      newItemIds.add(item.id);

      final itemShares = splitEqually(
        itemSplit.amount,
        itemSplit.userIds,
        expense.paidBy,
      );
      for (final userId in itemShares.keys) {
        final share = ExpenseShare(
          id: ExpenseShare.createItemShareId(item.id, userId),
          groupId: expense.groupId,
          expenseId: expense.id,
          itemId: item.id,
          userId: userId,
          amount: itemShares[userId]!,
          updatedAt: now,
        );
        await SyncService.saveRow('expense_shares', share.toMap());
        newShareIds.add(share.id);
      }
    }

    for (final oldShare in await getSharesOfExpense(expense.id)) {
      if (!newShareIds.contains(oldShare.id)) {
        final row = oldShare.toMap();
        row['deleted_at'] = now;
        row['updated_at'] = now;
        await SyncService.saveRow('expense_shares', row);
      }
    }
    for (final oldItem in await getItemsOfExpense(expense.id)) {
      if (!newItemIds.contains(oldItem.id)) {
        final row = oldItem.toMap();
        row['deleted_at'] = now;
        row['updated_at'] = now;
        await SyncService.saveRow('expense_items', row);
      }
    }
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

  // The active shares of one expense (to fill the form when editing it).
  static Future<List<ExpenseShare>> getSharesOfExpense(String expenseId) async {
    final db = await DatabaseHelper.getDatabase();
    final rows = await db.query(
      'expense_shares',
      where: 'expense_id = ? AND deleted_at IS NULL',
      whereArgs: [expenseId],
    );

    final shares = <ExpenseShare>[];
    for (final row in rows) {
      shares.add(ExpenseShare.fromMap(row));
    }
    return shares;
  }

  // The active receipt items of one expense, in the order this phone saved
  // them (rowid). Items downloaded from another phone may come in a
  // different order; that only changes the order in the form.
  static Future<List<ExpenseItem>> getItemsOfExpense(String expenseId) async {
    final db = await DatabaseHelper.getDatabase();
    final rows = await db.query(
      'expense_items',
      where: 'expense_id = ? AND deleted_at IS NULL',
      whereArgs: [expenseId],
      orderBy: 'rowid',
    );

    final items = <ExpenseItem>[];
    for (final row in rows) {
      items.add(ExpenseItem.fromMap(row));
    }
    return items;
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

  // Soft-deletes an expense with its shares and items: deleted_at is set,
  // nothing is really removed, so the deletion reaches the other phones.
  static Future<void> deleteExpense(Expense expense) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final expenseRow = expense.toMap();
    expenseRow['deleted_at'] = now;
    expenseRow['updated_at'] = now;
    await SyncService.saveRow('expenses', expenseRow);

    for (final share in await getSharesOfExpense(expense.id)) {
      final row = share.toMap();
      row['deleted_at'] = now;
      row['updated_at'] = now;
      await SyncService.saveRow('expense_shares', row);
    }
    for (final item in await getItemsOfExpense(expense.id)) {
      final row = item.toMap();
      row['deleted_at'] = now;
      row['updated_at'] = now;
      await SyncService.saveRow('expense_items', row);
    }
  }
}
