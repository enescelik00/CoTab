import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/group_service.dart';

// Asks for a group name and type and creates the group.
// On success it closes and returns the new Group to the home screen.
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _type = 'home';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateName(AppLocalizations texts, String? value) {
    if (value == null || value.trim().isEmpty) {
      return texts.groupNameRequired;
    }
    return null;
  }

  Future<void> _createGroup() async {
    final texts = AppLocalizations.of(context)!;

    // Stop here if the name is empty, so Firebase is not called.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final group = await GroupService.createGroup(
        _nameController.text.trim(),
        _type,
      );
      if (mounted) {
        Navigator.pop(context, group);
      }
      return;
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
      appBar: AppBar(title: Text(texts.createGroupTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: texts.groupNameLabel),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => _validateName(texts, value),
              ),
              const SizedBox(height: 24),
              Text(texts.groupTypeLabel),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'home',
                    icon: const Icon(Icons.home),
                    label: Text(texts.groupTypeHome),
                  ),
                  ButtonSegment(
                    value: 'trip',
                    icon: const Icon(Icons.flight),
                    label: Text(texts.groupTypeTrip),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) {
                  setState(() {
                    _type = selection.first;
                  });
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _createGroup,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(texts.createGroupButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
