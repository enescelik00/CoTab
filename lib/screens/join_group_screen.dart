import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../services/group_service.dart';
import '../utils/invite_code.dart';

// Asks for an invite code and joins that group.
// On success it closes and returns the Group to the home screen.
class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateCode(AppLocalizations texts, String? value) {
    if (value == null || value.trim().length != inviteCodeLength) {
      return texts.inviteCodeInvalidLength;
    }
    return null;
  }

  Future<void> _joinGroup() async {
    final texts = AppLocalizations.of(context)!;

    // Stop here if the code is wrong, so Firebase is not called.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final group = await GroupService.joinGroup(_codeController.text);
      if (mounted) {
        Navigator.pop(context, group);
      }
      return;
    } on InvalidInviteCodeException {
      if (mounted) {
        _showMessage(texts.joinErrorInvalidCode);
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        if (error.code == 'unavailable') {
          _showMessage(texts.errorNoInternet);
        } else {
          _showMessage(texts.errorUnknown);
        }
      }
    } catch (error) {
      if (mounted) {
        _showMessage(texts.errorUnknown);
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
      appBar: AppBar(title: Text(texts.joinGroupTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(texts.joinGroupHint),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(labelText: texts.inviteCodeLabel),
                maxLength: inviteCodeLength,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                // Shows the code in capital letters while the user types.
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(
                      text: newValue.text.toUpperCase(),
                    );
                  }),
                ],
                validator: (value) => _validateCode(texts, value),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isLoading ? null : _joinGroup,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(texts.joinGroupButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
