import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/group.dart';
import '../models/group_member.dart';
import '../utils/invite_code.dart';
import 'auth_service.dart';
import 'database_helper.dart';
import 'sync_service.dart';

// Thrown by joinGroup when no group has the typed invite code.
class InvalidInviteCodeException implements Exception {}

// Creating, joining and reading groups.
// Creating and joining need internet (the invite code is checked on the
// server), so they write to Firestore and to the local SQLite database.
// The lists on the screens are always read from SQLite.
// Firestore documents follow the sync convention in auth_service.dart:
// the document is the row map, the collection is the table name.
class GroupService {
  // Asks the server directly instead of the Firestore cache. Without
  // internet this throws a FirebaseException with the code 'unavailable'.
  static const GetOptions _fromServer = GetOptions(source: Source.server);

  static Future<Group> createGroup(String name, String type) async {
    final firestore = FirebaseFirestore.instance;
    final userId = AuthService.currentUserId!;
    final now = DateTime.now().millisecondsSinceEpoch;

    final inviteCode = await _createUniqueInviteCode();
    final group = Group(
      id: firestore.collection('groups').doc().id,
      name: name,
      type: type,
      inviteCode: inviteCode,
      updatedAt: now,
    );
    final member = GroupMember(
      id: GroupMember.createId(group.id, userId),
      groupId: group.id,
      userId: userId,
      role: 'admin',
      joinedAt: now,
      updatedAt: now,
    );

    await firestore.collection('groups').doc(group.id).set(group.toMap());
    await firestore
        .collection('group_members')
        .doc(member.id)
        .set(member.toMap());

    await SyncService.saveIfNewer('groups', group.toMap());
    await SyncService.saveIfNewer('group_members', member.toMap());
    return group;
  }

  static Future<Group> joinGroup(String inviteCode) async {
    final firestore = FirebaseFirestore.instance;
    final userId = AuthService.currentUserId!;
    final code = normalizeInviteCode(inviteCode);

    // Find the group with this code. Deleted groups are skipped here in
    // Dart, so Firestore does not need an extra index.
    final result = await firestore
        .collection('groups')
        .where('invite_code', isEqualTo: code)
        .get(_fromServer);
    Group? group;
    for (final document in result.docs) {
      final foundGroup = Group.fromMap(document.data());
      if (foundGroup.deletedAt == null) {
        group = foundGroup;
      }
    }
    if (group == null) {
      throw InvalidInviteCodeException();
    }

    // Add the user to the group, unless they are already an active member.
    final memberId = GroupMember.createId(group.id, userId);
    final memberDocument = await firestore
        .collection('group_members')
        .doc(memberId)
        .get(_fromServer);
    bool isActiveMember = false;
    if (memberDocument.exists) {
      isActiveMember = memberDocument.data()!['deleted_at'] == null;
    }
    if (!isActiveMember) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final member = GroupMember(
        id: memberId,
        groupId: group.id,
        userId: userId,
        role: 'member',
        joinedAt: now,
        updatedAt: now,
      );
      await firestore
          .collection('group_members')
          .doc(member.id)
          .set(member.toMap());
      await SyncService.saveIfNewer('group_members', member.toMap());
    }

    await SyncService.saveIfNewer('groups', group.toMap());
    // Downloads the other members (and later the expenses) of the group.
    await SyncService.pullGroup(group.id);
    return group;
  }

  // The groups of the signed-in user, read from SQLite only.
  static Future<List<Group>> getMyGroups() async {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      return [];
    }

    final db = await DatabaseHelper.getDatabase();
    final rows = await db.rawQuery(
      '''
      SELECT groups.* FROM groups
      JOIN group_members ON group_members.group_id = groups.id
      WHERE group_members.user_id = ?
        AND groups.deleted_at IS NULL
        AND group_members.deleted_at IS NULL
      ORDER BY groups.name COLLATE NOCASE
      ''',
      [userId],
    );

    final groups = <Group>[];
    for (final row in rows) {
      groups.add(Group.fromMap(row));
    }
    return groups;
  }

  // Downloads my memberships and my groups from Firestore and saves them
  // to SQLite. The rest of each group is downloaded by
  // SyncService.pullGroup. Throws without internet; SyncService.syncAll
  // catches that, so the screen keeps showing the local data.
  static Future<void> refreshMyGroups() async {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final memberships = await firestore
        .collection('group_members')
        .where('user_id', isEqualTo: userId)
        .get(_fromServer);

    for (final document in memberships.docs) {
      final member = GroupMember.fromMap(document.data());
      await SyncService.saveIfNewer('group_members', member.toMap());

      final groupDocument = await firestore
          .collection('groups')
          .doc(member.groupId)
          .get(_fromServer);
      if (groupDocument.exists) {
        final group = Group.fromMap(groupDocument.data()!);
        await SyncService.saveIfNewer('groups', group.toMap());
      }
    }
  }

  // The active members of a group with their names, read from SQLite.
  // Each row has the keys 'name' and 'role'.
  static Future<List<Map<String, Object?>>> getMembers(String groupId) async {
    final db = await DatabaseHelper.getDatabase();
    return db.rawQuery(
      '''
      SELECT users.name, group_members.role FROM group_members
      JOIN users ON users.id = group_members.user_id
      WHERE group_members.group_id = ?
        AND group_members.deleted_at IS NULL
      ORDER BY group_members.joined_at
      ''',
      [groupId],
    );
  }

  // Tries random codes until one is not used by any group yet.
  static Future<String> _createUniqueInviteCode() async {
    final random = Random.secure();
    for (int attempt = 0; attempt < 5; attempt++) {
      final code = generateInviteCode(random);
      final result = await FirebaseFirestore.instance
          .collection('groups')
          .where('invite_code', isEqualTo: code)
          .limit(1)
          .get(_fromServer);
      if (result.docs.isEmpty) {
        return code;
      }
    }
    throw Exception('Could not find a free invite code.');
  }
}
