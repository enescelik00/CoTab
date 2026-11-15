// A payment between two members: "I paid you back". It lowers the debt of
// fromUserId to toUserId. The amount is in kuruş.
class Settlement {
  final String id;
  final String groupId;
  final String fromUserId; // the person who paid
  final String toUserId; // the person who got the money
  final int amount;
  final int settledAt;
  final int updatedAt;
  final int? deletedAt;

  Settlement({
    required this.id,
    required this.groupId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.settledAt,
    required this.updatedAt,
    this.deletedAt,
  });

  // Converts the settlement to a map for the SQLite `settlements` table.
  // The Firestore document uses the same map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'amount': amount,
      'settled_at': settledAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  // Creates a settlement from a SQLite row or a Firestore document.
  factory Settlement.fromMap(Map<String, dynamic> map) {
    return Settlement(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      fromUserId: map['from_user_id'] as String,
      toUserId: map['to_user_id'] as String,
      amount: map['amount'] as int,
      settledAt: map['settled_at'] as int,
      updatedAt: map['updated_at'] as int,
      deletedAt: map['deleted_at'] as int?,
    );
  }
}
