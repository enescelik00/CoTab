// Money that one member paid for the group, for example a market bill.
// The amount is in kuruş (12.50 TL is 1250).
class Expense {
  final String id;
  final String groupId;
  final String title; // e.g. 'Migros' or 'Electricity bill'
  final int amount;
  final String paidBy; // user id of the person who paid
  final String category; // 'food', 'rent', 'bills', 'transport' or 'other'
  final int expenseDate;
  final String splitType; // 'equal', 'percentage' or 'exact'
  final String? receiptPath; // receipt image on this phone, if any
  final int updatedAt;
  final int? deletedAt;

  Expense({
    required this.id,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.category,
    required this.expenseDate,
    required this.splitType,
    this.receiptPath,
    required this.updatedAt,
    this.deletedAt,
  });

  // Converts the expense to a map for the SQLite `expenses` table.
  // The Firestore document uses the same map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'title': title,
      'amount': amount,
      'paid_by': paidBy,
      'category': category,
      'expense_date': expenseDate,
      'split_type': splitType,
      'receipt_path': receiptPath,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  // Creates an expense from a SQLite row or a Firestore document.
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      title: map['title'] as String,
      amount: map['amount'] as int,
      paidBy: map['paid_by'] as String,
      category: map['category'] as String,
      expenseDate: map['expense_date'] as int,
      splitType: map['split_type'] as String,
      receiptPath: map['receipt_path'] as String?,
      updatedAt: map['updated_at'] as int,
      deletedAt: map['deleted_at'] as int?,
    );
  }
}
