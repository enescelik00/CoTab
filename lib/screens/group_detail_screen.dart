import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/expense.dart';
import '../models/group.dart';
import '../services/auth_service.dart';
import '../services/expense_service.dart';
import '../services/group_service.dart';
import '../services/sync_service.dart';
import '../utils/balance_calculator.dart';
import '../widgets/expense_tile.dart';
import '../widgets/member_balance_tile.dart';
import 'add_expense_screen.dart';

// Shows one group: its invite code, its members with their balances and
// its expenses. New expenses are added with the button at the bottom.
class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  // Each member is a map with the keys 'user_id', 'name' and 'role'.
  List<Map<String, Object?>> _members = [];
  List<Expense> _expenses = [];
  // user id -> balance in kuruş (see balance_calculator.dart)
  Map<String, int> _balances = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Shows the data saved on the phone first, then downloads the latest
  // data of the group (new members, new expenses) and shows it again.
  Future<void> _loadData() async {
    await _readLocalData();
    await _refresh();
  }

  // Also used by pull-to-refresh: sends my changes, downloads the latest
  // data of the group and shows it.
  Future<void> _refresh() async {
    try {
      await SyncService.pushPending();
      await SyncService.pullGroup(widget.group.id);
    } catch (error) {
      // Probably offline. The local data is still shown.
    }
    await _readLocalData();
  }

  Future<void> _readLocalData() async {
    final groupId = widget.group.id;
    final members = await GroupService.getMembers(groupId);
    final expenses = await ExpenseService.getExpenses(groupId);
    final shares = await ExpenseService.getShares(groupId);

    final memberIds = <String>[];
    for (final member in members) {
      memberIds.add(member['user_id'] as String);
    }
    final balances = calculateBalances(memberIds, expenses, shares);

    if (!mounted) {
      return;
    }
    setState(() {
      _members = members;
      _expenses = expenses;
      _balances = balances;
    });
  }

  // The name of a member, or "Unknown" if they are not in the group.
  String _memberName(String userId) {
    for (final member in _members) {
      if (member['user_id'] == userId) {
        return member['name'] as String;
      }
    }
    return AppLocalizations.of(context)!.unknownMember;
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

  Future<void> _openAddExpense() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          group: widget.group,
          members: _members,
          currentUserId: AuthService.currentUserId!,
        ),
      ),
    );
    if (added == true) {
      await _readLocalData();
    }
  }

  // Asks "Delete this expense?" and deletes it if the user says yes.
  Future<void> _confirmDelete(Expense expense) async {
    final texts = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(texts.deleteExpenseTitle),
        content: Text(texts.deleteExpenseMessage(expense.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(texts.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(texts.deleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    await ExpenseService.deleteExpense(expense);
    await _readLocalData();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(texts.expenseDeleted)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name)),
      floatingActionButton: FloatingActionButton.extended(
        // Disabled until the members are loaded.
        onPressed: _members.isEmpty ? null : _openAddExpense,
        icon: const Icon(Icons.add),
        label: Text(texts.addExpenseTitle),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          // Extra space at the bottom so the button does not cover the
          // last expense.
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          children: [
            _buildInviteCodeCard(texts, textTheme),
            const SizedBox(height: 24),
            Text(texts.membersTitle, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            // All members in one card. It is left out while the members
            // are still loading, so no empty card is shown.
            if (_members.isNotEmpty)
              Card(
                child: Column(
                  children: [
                    for (final member in _members)
                      MemberBalanceTile(
                        name: member['name'] as String,
                        isAdmin: member['role'] == 'admin',
                        balance: _balances[member['user_id']] ?? 0,
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Text(texts.expensesTitle, style: textTheme.titleMedium),
            if (_expenses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(texts.noExpenses, textAlign: TextAlign.center),
              )
            else ...[
              Text(texts.expensesDeleteHint, style: textTheme.bodySmall),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    for (final expense in _expenses)
                      ExpenseTile(
                        expense: expense,
                        payerName: _memberName(expense.paidBy),
                        onLongPress: () => _confirmDelete(expense),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCodeCard(AppLocalizations texts, TextTheme textTheme) {
    final colors = Theme.of(context).colorScheme;

    return Card(
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
                    color: colors.primary,
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
            Text(
              texts.inviteCodeShareHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
