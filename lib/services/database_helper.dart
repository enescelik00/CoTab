import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'cotab.db';
  static const int _databaseVersion = 3;

  static Database? _database;

  // Opens the database the first time it is needed and reuses it afterwards.
  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
    );
    return _database!;
  }

  // Runs only once, when the database file is created for the first time.
  // IDs are TEXT because they will come from Firebase.
  // updated_at and deleted_at are milliseconds since epoch. They are used for
  // syncing: the newer updated_at wins, and a row with deleted_at set counts
  // as deleted (it is not removed, so the deletion can be synced too).
  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        avatar_url TEXT,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        currency TEXT NOT NULL,
        invite_code TEXT NOT NULL UNIQUE,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');

    await _createVersion2Tables(db);
    await _createVersion3Tables(db);
  }

  // Runs when the app finds a database file from an older app version.
  // Each step adds what that version introduced, so no data is lost.
  static Future<void> _upgradeTables(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createVersion2Tables(db);
    }
    if (oldVersion < 3) {
      await _createVersion3Tables(db);
    }
    // Next version goes here: if (oldVersion < 4) { ... }
  }

  // Added in version 2: group_members and sync_queue.
  static Future<void> _createVersion2Tables(Database db) async {
    // The id is '${groupId}_${userId}', so the same membership always gets
    // the same id on every phone.
    await db.execute('''
      CREATE TABLE group_members (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        role TEXT NOT NULL,
        joined_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');

    // The list of local changes that still have to be sent to Firestore
    // (see SyncService). It only lives on this phone and is never synced.
    // It is the one table without updated_at and deleted_at: a row is
    // really DELETEd once its change has reached the server.
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        row_id TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  // Added in version 3: expenses and everything that belongs to them.
  // Every table has group_id, so SyncService can download it per group.
  // All amounts are in kuruş (12.50 TL is 1250).
  static Future<void> _createVersion3Tables(Database db) async {
    // split_type is 'equal', 'percentage' or 'exact'.
    // category is 'food', 'rent', 'bills', 'transport' or 'other'.
    // receipt_path is the receipt image on this phone (empty if none).
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        title TEXT NOT NULL,
        amount INTEGER NOT NULL,
        paid_by TEXT NOT NULL,
        category TEXT NOT NULL,
        expense_date INTEGER NOT NULL,
        split_type TEXT NOT NULL,
        receipt_path TEXT,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');

    // The products on a scanned receipt (used later by receipt scanning).
    await db.execute('''
      CREATE TABLE expense_items (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        expense_id TEXT NOT NULL,
        name TEXT NOT NULL,
        amount INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');

    // How much of an expense each person owes. Only the final amount is
    // stored, also for percentage splits. item_id is set only when the
    // share belongs to one receipt item.
    await db.execute('''
      CREATE TABLE expense_shares (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        expense_id TEXT NOT NULL,
        item_id TEXT,
        user_id TEXT NOT NULL,
        amount INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');

    // A payment between two members ("I paid you back").
    await db.execute('''
      CREATE TABLE settlements (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        from_user_id TEXT NOT NULL,
        to_user_id TEXT NOT NULL,
        amount INTEGER NOT NULL,
        settled_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');
  }
}
