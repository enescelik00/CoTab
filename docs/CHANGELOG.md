# Changelog

Every change merged into `main` gets an entry here, newest first. Keep entries short: what changed, and why when it is not obvious.

Entry format:

```markdown
## YYYY-MM-DD — Short title (Author name)

- What changed
- Why, if it is not obvious
```

---

## 2026-11-15 — Team notes (Ahmet Anıl Çay)

- Added `docs/Ekip_Notlari.md` (Turkish) with the setup steps teammates need: Flutter and Java versions, Kotlin upgrade, Firebase configuration.
- Documented the data and sync rules: SQLite as the source of truth, `SyncService.saveRow`, sync columns, and database version ownership.

## 2026-11-15 — Offline sync (Ahmet Anıl Çay)

- New table `sync_queue` (id, table_name, row_id, created_at): the local changes that still have to be sent to Firestore. It is added in the same database version 2 step as `group_members`, because version 2 was not released yet. It is the only table without `updated_at`/`deleted_at`, and its rows are really deleted once sent.
- New `SyncService` (`lib/services/sync_service.dart`):
  - `saveRow(table, row)`: writes the row to SQLite, adds it to `sync_queue` and tries to send it right away. It never fails because of a missing internet connection.
  - `pushPending()`: sends the queued rows to Firestore, oldest first; stops at the first error and keeps the rest for later. A row queued several times is sent once.
  - `pullGroup(groupId)`: downloads the group, the rows of every table in `groupTables` with this `group_id`, and the members' users.
  - `syncAll()`: sends my changes, then downloads my groups and everything in them. Returns `false` when the server could not be reached.
  - `saveIfNewer` moved here from `GroupService` ("newer wins" by `updated_at`). Downloaded rows are never put back into the queue.
- The home screen syncs when it opens, on pull-to-refresh and when the app comes back to the foreground. Without internet it shows "You're offline — showing saved data" above the list (English and Turkish).
- The group screen downloads the latest group data with `pullGroup` when it opens. Joining a group also uses `pullGroup`; `GroupService.refreshMembers` was removed.
- Tests: the "is the remote row newer?" rule and picking one queue entry per row (`lib/utils/sync_rules.dart`).
- How to use from other modules: build the row with `updated_at` set to `DateTime.now().millisecondsSinceEpoch` (and `deleted_at` to delete it, never `DELETE`), then call `SyncService.saveRow('expenses', expense.toMap())`. Add the table name to `groupTables` in `sync_service.dart`. Every synced table needs `group_id`, `updated_at` and `deleted_at` columns.

## 2026-11-15 — Groups and invite codes (Ahmet Anıl Çay)

- Database version 2: new `group_members` table (id = `groupId_userId`, group_id, user_id, role, joined_at, updated_at, deleted_at). Old databases get it through `onUpgrade`. The next table change should be version 3; see the comment in `_upgradeTables` in `database_helper.dart`.
- Added the `Group` and `GroupMember` models.
- `GroupService` (`lib/services/group_service.dart`): create a group, join with an invite code, read my groups and the members of a group from SQLite, and download them from Firestore (`groups`, `group_members`, `users`). The newer `updated_at` wins when saving downloaded rows.
- Creating and joining need internet, because the invite code is checked on the server. They write to Firestore and to SQLite.
- Invite codes are 6 characters without look-alike characters such as 0/O and 1/I (`lib/utils/invite_code.dart`). The creator of a group is its admin.
- Home screen lists my groups (pull to refresh), with a "New group" button and a "Join a group" button.
- New screens: create group (name, home or trip), join group (invite code) and group detail (invite code with a copy button, members, a placeholder for expenses).
- Added English and Turkish texts for the new screens.
- Tests: `Group`/`GroupMember` map round trips, the invite code generator and the create/join form validation. `HomeScreen` takes an optional `groupLoader` so its test does not need SQLite or Firebase.

## 2026-11-15 — Sign up and sign in (Ahmet Anıl Çay)

- Added the sign-in and sign-up screens with form validation, a loading state and error messages in a SnackBar.
- "Forgot password?" sends a password reset email to the typed address.
- `AuthService` (`lib/services/auth_service.dart`) signs up, signs in and signs out with Firebase Auth, and saves the user to Firestore (`users/{uid}`) and to the local `users` table.
- Firestore documents use exactly the same fields as the SQLite row (`toMap()`): collection name = table name, document id = row id. The coming sync service relies on this.
- Added the `AppUser` model (`lib/models/app_user.dart`) that matches the `users` table.
- `main.dart` now starts with `AuthGate`: the sign-in screen when nobody is signed in, the home screen otherwise. `CoTabApp` takes an optional `home` so tests can run without Firebase.
- Home screen: added a sign-out button in the app bar.
- Added English and Turkish texts for the new screens and Firebase error messages.
- Tests: `AppUser` map round trip and sign-in form validation.

## 2026-11-15 — Firebase setup (Ahmet Anıl Çay)

- Added the packages `firebase_core`, `firebase_auth` and `cloud_firestore`.
- `main.dart` now initializes Firebase before `runApp`.
- Added the google-services Gradle plugin and `firebase.json` (generated by `flutterfire configure`).
- `google-services.json` and `firebase_options.dart` stay gitignored; each developer generates them (see README Setup).
- Firestore security rule in the Firebase console allows read and write only for signed-in users.
- iOS is not configured yet.
- README: added Firebase setup notes.
- Kotlin Gradle plugin raised from 2.2.20 to 2.4.21, because firebase_auth's Android library is built with Kotlin 2.4.
- Moved `kotlinOptions` to the new `kotlin { compilerOptions { ... } }` block (required by Kotlin 2.4) and ignored `android/.kotlin/`.

## 2026-11-01 — Sync columns and roadmap decisions (Enes Çelik)

- Added `updated_at` and `deleted_at` (INTEGER, milliseconds since epoch) to the `users` and `groups` tables. Every future table except `sync_queue` gets them too: the newer `updated_at` wins when syncing, and rows are soft-deleted with `deleted_at`.
- QR invites moved from the MVP to Phase 2. The MVP uses invite codes only.
- Receipt images stay on the phone that scanned them for now; no Firebase Storage.
- Branch names are in English (`feature/receipt-scan`). The roadmap now lists `refactor:` as a commit type, like the README.
- README: updated the tech stack (setState, Navigator, sqflite, local notifications) and the team table, and added the changelog rule.
- Roadmap: the project skeleton is now listed under Enes Çelik; the Phase 2 Turkish item became "review the Turkish translations".
- Roadmap: noted how the plan now differs from the scope and work plan document sent to the instructor (skeleton owner, simpler tech stack); these are reported in the first weekly report.

## 2026-11-01 — Project skeleton (Enes Çelik)

- Created the Flutter project: name `cotab`, package id `io.github.enescelik00.cotab`, Android and iOS only. The app is shown as "CoTab" on both platforms.
- Moved `README.md` from `docs/` to the project root. `docs/Road_Map.md` stays in `docs/`.
- Added packages: `sqflite`, `path`, `flutter_localizations`, `intl`. Removed `cupertino_icons` (we only use Material icons).
- Created the folder structure: `lib/models`, `lib/screens`, `lib/services`, `lib/widgets`, `lib/utils`.
- Added `lib/services/database_helper.dart`: opens `cotab.db` and creates the `users` and `groups` tables with plain SQL. IDs are `TEXT` because they will come from Firebase.
- Added `lib/main.dart` (Material 3 theme) and an empty home screen in `lib/screens/home_screen.dart`.
- Set up localization: English is the default, Turkish is the second language (`l10n.yaml`, `lib/l10n/app_en.arb`, `lib/l10n/app_tr.arb`). The generated `app_localizations*.dart` files are committed.
- Replaced the default counter test with a test that checks the home screen opens.
- `.gitignore`: removed the `*.lock` rule so `pubspec.lock` is committed and everyone uses the same package versions. Added IDE folders and Firebase config files (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`).
- Added `CLAUDE.md` with the project rules and this changelog.
