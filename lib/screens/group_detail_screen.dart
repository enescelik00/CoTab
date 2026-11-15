import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/group.dart';
import '../services/group_service.dart';

// Shows one group: its invite code, its members and (later) its expenses.
class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  // Each member is a map with the keys 'name' and 'role'.
  List<Map<String, Object?>> _members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  // Shows the members saved on the phone first, then downloads the latest
  // list (someone may have joined) and shows it again.
  Future<void> _loadMembers() async {
    await _readLocalMembers();
    try {
      await GroupService.refreshMembers(widget.group.id);
      await _readLocalMembers();
    } catch (error) {
      // Probably offline. The local list is still shown.
    }
  }

  Future<void> _readLocalMembers() async {
    final members = await GroupService.getMembers(widget.group.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _members = members;
    });
  }

  Future<void> _copyInviteCode() async {
    final texts = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: widget.group.inviteCode));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(texts.inviteCodeCopied)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(texts.inviteCodeLabel, style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.group.inviteCode,
                        style: textTheme.headlineLarge?.copyWith(
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: texts.inviteCodeCopy,
                        onPressed: _copyInviteCode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(texts.inviteCodeShareHint, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(texts.membersTitle, style: textTheme.titleMedium),
          for (final member in _members)
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(member['name'] as String),
              trailing: member['role'] == 'admin'
                  ? Text(texts.memberRoleAdmin)
                  : null,
            ),
          const SizedBox(height: 24),
          // Placeholder until the expenses module (Enes Çelik) is ready.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                texts.expensesPlaceholder,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
