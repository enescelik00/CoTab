import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/sync_rules.dart';
import 'auth_service.dart';
import 'database_helper.dart';
import 'group_service.dart';

// Offline-first sync between the local SQLite database and Firestore.
//
// The idea:
// - The app always reads from and writes to SQLite, so it works offline.
// - Every local change is also written to the sync_queue table. When
//   there is internet, pushPending() sends the queued rows to Firestore.
// - Changes of the other group members are downloaded with pullGroup()
//   and syncAll(). A downloaded row only replaces the local row if it is
//   newer ("newer wins", compared by updated_at).
// - A Firestore document is exactly the SQLite row (same keys), the
//   collection name is the table name and the document id is the row id.
//
// How to use it from another module (for example expenses):
// 1. Build the row and set updated_at to
//    DateTime.now().millisecondsSinceEpoch. To delete a row, also set
//    deleted_at (never DELETE it).
// 2. Call SyncService.saveRow('expenses', expense.toMap());
// 3. Add the table name to groupTables below, so other phones download it.
// Every synced table needs the columns group_id, updated_at and deleted_at.
class SyncService {
  // The tables that belong to one group. pullGroup() downloads the rows of
  // these tables where group_id is the given group, so each of them must
  // have a group_id column.
  static const List<String> groupTables = [
    'group_members',
    'expenses',
    'expense_items',
    'expense_shares',
    'settlements',
  ];

  // Asks the server directly instead of the Firestore cache. Without
  // internet this throws, so we know that we are offline.
  static const GetOptions _fromServer = GetOptions(source: Source.server);

  // Offline, a Firestore write waits until there is internet again. We do
  // not wait that long; the row stays in the queue and is sent later.
  static const Duration _pushTimeout = Duration(seconds: 10);

  // True while pushPending() is running, so it never runs twice at the
  // same time (that could send the same row twice).
  static bool _isPushing = false;

  // The one function other modules call to change synced data.
  // The caller must already have set updated_at (and deleted_at for a
  // soft delete) in the row.
  static Future<void> saveRow(String table, Map<String, Object?> row) async {
    final db = await DatabaseHelper.getDatabase();
    await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('sync_queue', {
      'table_name': table,
      'row_id': row['id'],
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });

    // Not awaited: the caller does not wait for the network.
    unawaited(_pushInBackground());
  }

  static Future<void> _pushInBackground() async {
    try {
      await pushPending();
    } catch (error) {
      // Probably offline. The rows stay in the queue for the next sync.
    }
  }

  // Sends the queued local changes to Firestore, oldest first.
  // Throws at the first error (for example offline); the entries that were
  // not sent stay in the queue for the next try.
  static Future<void> pushPending() async {
    if (_isPushing) {
      return;
    }
    _isPushing = true;

    try {
      final db = await DatabaseHelper.getDatabase();
      final entries = await db.query('sync_queue', orderBy: 'id');

      for (final entry in latestEntryPerRow(entries)) {
        final table = entry['table_name'] as String;
        final rowId = entry['row_id'] as String;

        // Send the row as it is now, so the latest change is sent.
        final rows = await db.query(table, where: 'id = ?', whereArgs: [rowId]);
        if (rows.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection(table)
              .doc(rowId)
              .set(rows.first)
              .timeout(_pushTimeout);
        }

        // The change is on the server now, so remove it from the queue.
        // This removes the older entries of the same row too, but not the
        // ones added while we were sending (they have a higher id).
        // sync_queue is the only table where rows are really deleted.
        await db.delete(
          'sync_queue',
          where: 'table_name = ? AND row_id = ? AND id <= ?',
          whereArgs: [table, rowId, entry['id']],
        );
      }
    } finally {
      _isPushing = false;
    }
  }

  // "Newer wins": saves a downloaded row only if it is not in the table
  // yet or if its updated_at is newer than the local one.
  // It does not add anything to the sync_queue, because the row came from
  // the server and does not need to be sent back.
  static Future<void> saveIfNewer(
    String table,
    Map<String, dynamic> row,
  ) async {
    final db = await DatabaseHelper.getDatabase();
    final localRows = await db.query(
      table,
      columns: ['updated_at'],
      where: 'id = ?',
      whereArgs: [row['id']],
    );

    int? localUpdatedAt;
    if (localRows.isNotEmpty) {
      localUpdatedAt = localRows.first['updated_at'] as int;
    }
    final remoteUpdatedAt = row['updated_at'] as int;
    if (!isRemoteNewer(localUpdatedAt, remoteUpdatedAt)) {
      return;
    }
    await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Downloads everything of one group: the group itself, the rows of all
  // groupTables and the users who are members (for their names).
  // Throws without internet.
  static Future<void> pullGroup(String groupId) async {
    final firestore = FirebaseFirestore.instance;

    final groupDocument = await firestore
        .collection('groups')
        .doc(groupId)
        .get(_fromServer);
    if (groupDocument.exists) {
      await saveIfNewer('groups', groupDocument.data()!);
    }

    for (final table in groupTables) {
      final result = await firestore
          .collection(table)
          .where('group_id', isEqualTo: groupId)
          .get(_fromServer);
      for (final document in result.docs) {
        await saveIfNewer(table, document.data());
      }
    }

    await _pullMemberUsers(groupId);
  }

  // Downloads the users of all members of a group, so the member names
  // can be shown offline later. The members were just saved to SQLite.
  static Future<void> _pullMemberUsers(String groupId) async {
    final db = await DatabaseHelper.getDatabase();
    final members = await db.query(
      'group_members',
      columns: ['user_id'],
      where: 'group_id = ?',
      whereArgs: [groupId],
    );

    for (final member in members) {
      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(member['user_id'] as String)
          .get(_fromServer);
      if (userDocument.exists) {
        await saveIfNewer('users', userDocument.data()!);
      }
    }
  }

  // Sends my changes, then downloads my groups and everything in them.
  // Returns false when the server could not be reached (offline). The
  // local data is still there, so offline just means "nothing new".
  static Future<bool> syncAll() async {
    if (AuthService.currentUserId == null) {
      return true;
    }

    try {
      await pushPending();
      await GroupService.refreshMyGroups();

      final groups = await GroupService.getMyGroups();
      for (final group in groups) {
        await pullGroup(group.id);
      }
      return true;
    } catch (error) {
      return false;
    }
  }
}
