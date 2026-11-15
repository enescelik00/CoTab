// A user of the app. The id is the Firebase Auth uid.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int updatedAt;
  final int? deletedAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.updatedAt,
    this.deletedAt,
  });

  // Converts the user to a map for the SQLite `users` table.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  // Creates a user from a row of the SQLite `users` table.
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      avatarUrl: map['avatar_url'] as String?,
      updatedAt: map['updated_at'] as int,
      deletedAt: map['deleted_at'] as int?,
    );
  }
}
