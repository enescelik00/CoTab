import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../utils/auth_error_message.dart';
import '../utils/validators.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateConfirmPassword(AppLocalizations texts, String? value) {
    if (value != _passwordController.text) {
      return texts.passwordsDoNotMatch;
    }
    return null;
  }

  Future<void> _signUp() async {
    final texts = AppLocalizations.of(context)!;

    // Stop here if a field is wrong, so Firebase is not called.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      // The user is signed in now. Go back; the AuthGate in main.dart
      // already shows the home screen under this screen.
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        _showMessage(authErrorMessage(texts, error.code));
      }
    } catch (error) {
      if (mounted) {
        _showMessage(texts.authErrorUnknown);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(texts.signUpTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: texts.nameLabel),
                textCapitalization: TextCapitalization.words,
                validator: (value) => validateName(texts, value),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: texts.confirmPasswordLabel,
                ),
                obscureText: true,
                validator: (value) => _validateConfirmPassword(texts, value),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(texts.signUpButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
