// How much of an expense one member has to pay. The amount is in kuruş.
// For a percentage split, only the calculated amount is stored.
class ExpenseShare {
  final String id;
  final String groupId;
  final String expenseId;
  final String? itemId; // set only when the share is for one receipt item
  final String userId;
  final int amount;
  final int updatedAt;
  final int? deletedAt;

  ExpenseShare({
    required this.id,
    required this.groupId,
    required this.expenseId,
    this.itemId,
    required this.userId,
    required this.amount,
    required this.updatedAt,
    this.deletedAt,
  });

  // The same user in the same expense always gets the same id, so editing
  // an expense updates the old share instead of adding a second one.
  static String createId(String expenseId, String userId) {
    return '${expenseId}_$userId';
  }

  // The same for a share of one receipt item: one share per item and user.
  static String createItemShareId(String itemId, String userId) {
    return '${itemId}_$userId';
  }

  // Converts the share to a map for the SQLite `expense_shares` table.
  // The Firestore document uses the same map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'expense_id': expenseId,
      'item_id': itemId,
      'user_id': userId,
      'amount': amount,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  // Creates a share from a SQLite row or a Firestore document.
  factory ExpenseShare.fromMap(Map<String, dynamic> map) {
    return ExpenseShare(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      expenseId: map['expense_id'] as String,
      itemId: map['item_id'] as String?,
      userId: map['user_id'] as String,
      amount: map['amount'] as int,
      updatedAt: map['updated_at'] as int,
      deletedAt: map['deleted_at'] as int?,
    );
  }
}
