// One product on a scanned receipt, for example 'Süt 1L'.
// The amount is in kuruş. Used by receipt scanning.
class ExpenseItem {
  final String id;
  final String groupId;
  final String expenseId;
  final String name;
  final int amount;
  final int updatedAt;
  final int? deletedAt;

  ExpenseItem({
    required this.id,
    required this.groupId,
    required this.expenseId,
    required this.name,
    required this.amount,
    required this.updatedAt,
    this.deletedAt,
  });

  // Converts the item to a map for the SQLite `expense_items` table.
  // The Firestore document uses the same map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'expense_id': expenseId,
      'name': name,
      'amount': amount,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  // Creates an item from a SQLite row or a Firestore document.
  factory ExpenseItem.fromMap(Map<String, dynamic> map) {
    return ExpenseItem(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      expenseId: map['expense_id'] as String,
      name: map['name'] as String,
      amount: map['amount'] as int,
      updatedAt: map['updated_at'] as int,
      deletedAt: map['deleted_at'] as int?,
    );
  }
}
