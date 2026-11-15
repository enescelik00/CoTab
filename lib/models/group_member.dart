// Says that a user is in a group. The creator of a group is its 'admin',
// everybody who joins later is a 'member'.
class GroupMember {
  final String id;
  final String groupId;
  final String userId;
  final String role; // 'admin' or 'member'
  final int joinedAt;
  final int updatedAt;
  final int? deletedAt;

  GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.updatedAt,
    this.deletedAt,
  });

  // The same user in the same group always gets the same id, so joining
  // twice does not create two memberships.
  static String createId(String groupId, String userId) {
    return '${groupId}_$userId';
  }

  // Converts the membership to a map for the SQLite `group_members` table.
  // The Firestore document uses the same map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  // Creates a membership from a SQLite row or a Firestore document.
  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      userId: map['user_id'] as String,
      role: map['role'] as String,
      joinedAt: map['joined_at'] as int,
      updatedAt: map['updated_at'] as int,
      deletedAt: map['deleted_at'] as int?,
    );
  }
}
