import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'sign_in_screen.dart';

// Shows the sign-in screen when nobody is signed in and the home screen
// when a user is signed in. It rebuilds by itself every time the user signs
// in or out.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase has not told us yet whether someone is signed in.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return const SignInScreen();
        }
        return const HomeScreen();
      },
    );
  }
}
