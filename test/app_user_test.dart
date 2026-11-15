import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/models/app_user.dart';

void main() {
  test('AppUser keeps all fields after toMap and fromMap', () {
    final user = AppUser(
      id: 'uid123',
      name: 'Ayşe',
      email: 'ayse@example.com',
      avatarUrl: 'https://example.com/ayse.png',
      updatedAt: 1763200000000,
      deletedAt: 1763300000000,
    );

    final copy = AppUser.fromMap(user.toMap());

    expect(copy.id, 'uid123');
    expect(copy.name, 'Ayşe');
    expect(copy.email, 'ayse@example.com');
    expect(copy.avatarUrl, 'https://example.com/ayse.png');
    expect(copy.updatedAt, 1763200000000);
    expect(copy.deletedAt, 1763300000000);
  });

  test('toMap uses the column names of the users table', () {
    final user = AppUser(
      id: 'uid123',
      name: 'Ayşe',
      email: 'ayse@example.com',
      updatedAt: 1763200000000,
    );

    final map = user.toMap();

    expect(map['avatar_url'], isNull);
    expect(map['updated_at'], 1763200000000);
    expect(map['deleted_at'], isNull);
    expect(AppUser.fromMap(map).avatarUrl, isNull);
  });
}
