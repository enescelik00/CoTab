import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/models/group.dart';
import 'package:cotab/models/group_member.dart';

void main() {
  test('Group keeps all fields after toMap and fromMap', () {
    final group = Group(
      id: 'group1',
      name: 'Kadıköy Evi',
      type: 'home',
      currency: 'EUR',
      inviteCode: 'K7M2QX',
      updatedAt: 1763200000000,
      deletedAt: 1763300000000,
    );

    final copy = Group.fromMap(group.toMap());

    expect(copy.id, 'group1');
    expect(copy.name, 'Kadıköy Evi');
    expect(copy.type, 'home');
    expect(copy.currency, 'EUR');
    expect(copy.inviteCode, 'K7M2QX');
    expect(copy.updatedAt, 1763200000000);
    expect(copy.deletedAt, 1763300000000);
  });

  test('Group uses TRY by default and the column names of the table', () {
    final group = Group(
      id: 'group1',
      name: 'Kapadokya',
      type: 'trip',
      inviteCode: 'ABC234',
      updatedAt: 1763200000000,
    );

    final map = group.toMap();

    expect(map['currency'], 'TRY');
    expect(map['invite_code'], 'ABC234');
    expect(map['updated_at'], 1763200000000);
    expect(map['deleted_at'], isNull);
    expect(Group.fromMap(map).deletedAt, isNull);
  });

  test('GroupMember keeps all fields after toMap and fromMap', () {
    final member = GroupMember(
      id: GroupMember.createId('group1', 'uid123'),
      groupId: 'group1',
      userId: 'uid123',
      role: 'admin',
      joinedAt: 1763100000000,
      updatedAt: 1763200000000,
      deletedAt: 1763300000000,
    );

    final copy = GroupMember.fromMap(member.toMap());

    expect(copy.id, 'group1_uid123');
    expect(copy.groupId, 'group1');
    expect(copy.userId, 'uid123');
    expect(copy.role, 'admin');
    expect(copy.joinedAt, 1763100000000);
    expect(copy.updatedAt, 1763200000000);
    expect(copy.deletedAt, 1763300000000);
  });

  test('GroupMember toMap uses the column names of the table', () {
    final member = GroupMember(
      id: 'group1_uid123',
      groupId: 'group1',
      userId: 'uid123',
      role: 'member',
      joinedAt: 1763100000000,
      updatedAt: 1763100000000,
    );

    final map = member.toMap();

    expect(map['group_id'], 'group1');
    expect(map['user_id'], 'uid123');
    expect(map['joined_at'], 1763100000000);
    expect(map['deleted_at'], isNull);
  });
}
