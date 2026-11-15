// Small rules used by SyncService. They do not touch SQLite or Firebase,
// so they can be tested with plain unit tests.

// "Newer wins": a row downloaded from Firestore replaces the local row
// only if there is no local row yet (localUpdatedAt is null) or if the
// downloaded row was changed later than the local one.
bool isRemoteNewer(int? localUpdatedAt, int remoteUpdatedAt) {
  if (localUpdatedAt == null) {
    return true;
  }
  return remoteUpdatedAt > localUpdatedAt;
}

// The same row can be in the sync_queue several times (for example an
// expense that was edited twice while offline). Sending the current row
// once is enough, so this keeps one entry per row: the one with the
// highest id, which is the latest change.
// The rows stay in the order in which they were first changed, so a row
// that was created first is also sent first.
// Each entry is a sync_queue row with the keys 'id', 'table_name' and
// 'row_id'. The entries must be ordered by id.
List<Map<String, Object?>> latestEntryPerRow(
  List<Map<String, Object?>> entries,
) {
  final result = <Map<String, Object?>>[];
  // Remembers where each row is in the result, e.g. 'expenses/abc' -> 0.
  final positions = <String, int>{};

  for (final entry in entries) {
    final key = '${entry['table_name']}/${entry['row_id']}';
    final position = positions[key];
    if (position == null) {
      positions[key] = result.length;
      result.add(entry);
    } else {
      // A later change of a row we already have: keep the later entry,
      // but in the place of the first one.
      result[position] = entry;
    }
  }
  return result;
}
