import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';
import 'database_helper.dart';

// Sign up, sign in and sign out with Firebase Auth.
// The signed-in user is also saved to Firestore (users/{uid}) and to the
// local SQLite `users` table.
class AuthService {
  // The uid of the signed-in user, or null when nobody is signed in.
  static String? get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static Future<AppUser> signUp(
    String name,
    String email,
    String password,
  ) async {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    final firebaseUser = credential.user!;
    await firebaseUser.updateDisplayName(name);

    final user = AppUser(
      id: firebaseUser.uid,
      name: name,
      email: email,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _saveToFirestore(user);
    await _saveToLocalDatabase(user);
    return user;
  }

  static Future<AppUser> signIn(String email, String password) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = credential.user!;

    final document = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    AppUser user;
    if (document.exists) {
      user = AppUser.fromMap(document.data()!);
    } else {
      // The user exists in Firebase Auth but not in Firestore yet.
      final userEmail = firebaseUser.email ?? email;
      String name = firebaseUser.displayName ?? '';
      if (name.isEmpty) {
        name = userEmail.split('@').first;
      }
      user = AppUser(
        id: firebaseUser.uid,
        name: name,
        email: userEmail,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _saveToFirestore(user);
    }

    await _saveToLocalDatabase(user);
    return user;
  }

  static Future<void> sendPasswordReset(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // Sync convention: a Firestore document is exactly the SQLite row map
  // (same keys), the collection name is the table name and the document id
  // is the row id.
  static Future<void> _saveToFirestore(AppUser user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toMap());
  }

  // Inserts the user, or replaces the row if it already exists.
  static Future<void> _saveToLocalDatabase(AppUser user) async {
    final db = await DatabaseHelper.getDatabase();
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
