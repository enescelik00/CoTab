import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/utils/sync_rules.dart';

void main() {
  group('isRemoteNewer', () {
    test('A row that is not on the phone yet is saved', () {
      expect(isRemoteNewer(null, 1000), true);
    });

    test('A newer remote row replaces the local row', () {
      expect(isRemoteNewer(1000, 2000), true);
    });

    test('An older remote row is ignored', () {
      expect(isRemoteNewer(2000, 1000), false);
    });

    test('The same updated_at keeps the local row', () {
      expect(isRemoteNewer(1000, 1000), false);
    });
  });

  group('latestEntryPerRow', () {
    test('An empty queue stays empty', () {
      expect(latestEntryPerRow([]), isEmpty);
    });

    test('Keeps the latest entry of each row in first-change order', () {
      final entries = [
        {'id': 1, 'table_name': 'expenses', 'row_id': 'a'},
        {'id': 2, 'table_name': 'expense_shares', 'row_id': 'a'},
        {'id': 3, 'table_name': 'expenses', 'row_id': 'b'},
        {'id': 4, 'table_name': 'expenses', 'row_id': 'a'},
      ];

      final result = latestEntryPerRow(entries);

      // 'expenses/a' is still first, but with the later id 4.
      // 'expense_shares/a' is a different row, even with the same row_id.
      expect(result.length, 3);
      expect(result[0]['id'], 4);
      expect(result[1]['id'], 2);
      expect(result[2]['id'], 3);
    });
  });
}
