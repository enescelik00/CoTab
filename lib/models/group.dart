// A group of people who share expenses: a student house or a trip.
class Group {
  final String id;
  final String name;
  final String type; // 'home' or 'trip'
  final String currency; // e.g. 'TRY'
  final String inviteCode;
  final int updatedAt;
  final int? deletedAt;

  Group({
    required this.id,
    required this.name,
    required this.type,
    this.currency = 'TRY',
    required this.inviteCode,
    required this.updatedAt,
    this.deletedAt,
  });

  // Converts the group to a map for the SQLite `groups` table.
  // The Firestore document uses the same map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'currency': currency,
      'invite_code': inviteCode,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  // Creates a group from a SQLite row or a Firestore document.
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      currency: map['currency'] as String,
      inviteCode: map['invite_code'] as String,
      updatedAt: map['updated_at'] as int,
      deletedAt: map['deleted_at'] as int?,
    );
  }
}
