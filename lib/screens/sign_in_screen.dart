import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../utils/auth_error_message.dart';
import '../utils/validators.dart';
import '../widgets/app_logo_header.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signIn() async {
    final texts = AppLocalizations.of(context)!;

    // Stop here if a field is wrong, so Firebase is not called.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // On success the AuthGate in main.dart shows the home screen.
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        _showMessage(authErrorMessage(texts, error.code));
      }
    } catch (error) {
      if (mounted) {
        _showMessage(texts.authErrorUnknown);
      }
    }

    // The screen may already be gone, because the user is signed in now.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendPasswordReset() async {
    final texts = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();

    // Check only the email field; the password is not needed here.
    final emailError = validateEmail(texts, email);
    if (emailError != null) {
      _showMessage(emailError);
      return;
    }

    try {
      await AuthService.sendPasswordReset(email);
      if (mounted) {
        _showMessage(texts.passwordResetSent(email));
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        _showMessage(authErrorMessage(texts, error.code));
      }
    } catch (error) {
      if (mounted) {
        _showMessage(texts.authErrorUnknown);
      }
    }
  }

  void _openSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(texts.signInTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppLogoHeader(),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: texts.emailLabel),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => validateEmail(texts, value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: texts.passwordLabel),
                obscureText: true,
                validator: (value) => validatePassword(texts, value),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading ? null : _sendPasswordReset,
                  child: Text(texts.forgotPassword),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(texts.signInTitle),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : _openSignUp,
                child: Text(texts.noAccountSignUp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
