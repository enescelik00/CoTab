import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/settlement.dart';
import 'database_helper.dart';
import 'sync_service.dart';

// Saving, reading and deleting payments between members ("I paid you
// back"). Like expenses, everything is saved with SyncService.saveRow, so
// it works offline and reaches the other members when there is internet.
class SettlementService {
  // Saves that fromUserId paid toUserId the amount (in kuruş) just now.
  static Future<void> addSettlement({
    required String groupId,
    required String fromUserId,
    required String toUserId,
    required int amount,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Firestore can create a new id without internet.
    final settlement = Settlement(
      id: FirebaseFirestore.instance.collection('settlements').doc().id,
      groupId: groupId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      amount: amount,
      settledAt: now,
      updatedAt: now,
    );
    await SyncService.saveRow('settlements', settlement.toMap());
  }

  // The payments of a group, newest first.
  static Future<List<Settlement>> getSettlements(String groupId) async {
    final db = await DatabaseHelper.getDatabase();
    final rows = await db.query(
      'settlements',
      where: 'group_id = ? AND deleted_at IS NULL',
      whereArgs: [groupId],
      orderBy: 'settled_at DESC',
    );

    final settlements = <Settlement>[];
    for (final row in rows) {
      settlements.add(Settlement.fromMap(row));
    }
    return settlements;
  }

  // Soft-deletes a payment, for example one that was saved by mistake.
  static Future<void> deleteSettlement(Settlement settlement) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final row = settlement.toMap();
    row['deleted_at'] = now;
    row['updated_at'] = now;
    await SyncService.saveRow('settlements', row);
  }
}
