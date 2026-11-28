import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/expense.dart';
import '../models/group.dart';
import '../models/settlement.dart';
import '../services/auth_service.dart';
import '../services/expense_service.dart';
import '../services/group_service.dart';
import '../services/settlement_service.dart';
import '../services/sync_service.dart';
import '../utils/balance_calculator.dart';
import '../utils/debt_simplifier.dart';
import '../widgets/expense_tile.dart';
import '../widgets/member_balance_tile.dart';
import '../widgets/settle_up_dialog.dart';
import '../widgets/settlement_tile.dart';
import '../widgets/suggested_payment_tile.dart';
import 'add_expense_screen.dart';
import 'receipt_camera_screen.dart';

// Shows one group: its invite code, its members with their balances, the
// suggested payments to settle up, and its expenses and payments.
// New expenses are added with the button at the bottom.
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
  List<Settlement> _settlements = [];
  // user id -> balance in kuruş (see balance_calculator.dart)
  Map<String, int> _balances = {};
  // Who should pay whom to settle up (see debt_simplifier.dart).
  List<SuggestedPayment> _suggestions = [];

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
    final settlements = await SettlementService.getSettlements(groupId);

    final memberIds = <String>[];
    for (final member in members) {
      memberIds.add(member['user_id'] as String);
    }
    final balances = calculateBalances(
      memberIds,
      expenses,
      shares,
      settlements: settlements,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _members = members;
      _expenses = expenses;
      _settlements = settlements;
      _balances = balances;
      _suggestions = simplifyDebts(balances);
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

  // Opens the expense form filled with this expense and its shares.
  Future<void> _openEditExpense(Expense expense) async {
    final texts = AppLocalizations.of(context)!;
    final shares = await ExpenseService.getSharesOfExpense(expense.id);
    final items = await ExpenseService.getItemsOfExpense(expense.id);
    if (!mounted) {
      return;
    }

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          group: widget.group,
          members: _members,
          currentUserId: AuthService.currentUserId!,
          expense: expense,
          shares: shares,
          items: items,
        ),
      ),
    );
    if (saved == true) {
      await _readLocalData();
      if (mounted) {
        _showMessage(texts.expenseUpdated);
      }
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Shows a "Delete ...?" dialog. Returns true if the user tapped Delete.
  Future<bool> _askToDelete(String title, String message) async {
    final texts = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
    return confirmed == true;
  }

  Future<void> _deleteExpense(Expense expense) async {
    final texts = AppLocalizations.of(context)!;
    final confirmed = await _askToDelete(
      texts.deleteExpenseTitle,
      texts.deleteExpenseMessage(expense.title),
    );
    if (!confirmed) {
      return;
    }

    await ExpenseService.deleteExpense(expense);
    await _readLocalData();
    if (mounted) {
      _showMessage(texts.expenseDeleted);
    }
  }

  Future<void> _deleteSettlement(Settlement settlement) async {
    final texts = AppLocalizations.of(context)!;
    final confirmed = await _askToDelete(
      texts.deletePaymentTitle,
      texts.deletePaymentMessage,
    );
    if (!confirmed) {
      return;
    }

    await SettlementService.deleteSettlement(settlement);
    await _readLocalData();
    if (mounted) {
      _showMessage(texts.paymentDeleted);
    }
  }

  // "Paid" was tapped on a suggested payment: asks how much was paid and
  // saves it as a settlement. The balances and suggestions are then
  // calculated again, so the paid suggestion gets smaller or disappears.
  Future<void> _recordPayment(SuggestedPayment suggestion) async {
    final texts = AppLocalizations.of(context)!;

    final amount = await showDialog<int>(
      context: context,
      builder: (context) => SettleUpDialog(
        fromName: _memberName(suggestion.fromUserId),
        toName: _memberName(suggestion.toUserId),
        suggestedAmount: suggestion.amount,
      ),
    );
    if (amount == null) {
      return;
    }

    await SettlementService.addSettlement(
      groupId: widget.group.id,
      fromUserId: suggestion.fromUserId,
      toUserId: suggestion.toUserId,
      amount: amount,
    );
    await _readLocalData();
    if (mounted) {
      _showMessage(texts.paymentSaved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReceiptCameraScreen(),
              ),
            ),
            icon: const Icon(Icons.document_scanner_outlined),
            tooltip: texts.scanReceiptTitle,
          ),
        ],
      ),
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
            // Settling up only makes sense once something was spent.
            if (_expenses.isNotEmpty || _settlements.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(texts.settleUpTitle, style: textTheme.titleMedium),
              Text(texts.settleUpHint, style: textTheme.bodySmall),
              const SizedBox(height: 8),
              _buildSettleUpCard(texts),
            ],
            const SizedBox(height: 24),
            Text(texts.expensesTitle, style: textTheme.titleMedium),
            if (_expenses.isEmpty && _settlements.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(texts.noExpenses, textAlign: TextAlign.center),
              )
            else ...[
              Text(texts.expensesDeleteHint, style: textTheme.bodySmall),
              const SizedBox(height: 8),
              Card(child: Column(children: _buildHistoryTiles())),
            ],
          ],
        ),
      ),
    );
  }

  // The suggested payments, or "Everybody is settled up."
  Widget _buildSettleUpCard(AppLocalizations texts) {
    if (_suggestions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(texts.allSettledUp, textAlign: TextAlign.center),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          for (final suggestion in _suggestions)
            SuggestedPaymentTile(
              fromName: _memberName(suggestion.fromUserId),
              toName: _memberName(suggestion.toUserId),
              amount: suggestion.amount,
              onPaid: () => _recordPayment(suggestion),
            ),
        ],
      ),
    );
  }

  // Expenses and payments in one list, newest first.
  // Both lists are already sorted newest first, so we walk through them
  // together and always take the newer of the two next rows.
  List<Widget> _buildHistoryTiles() {
    final tiles = <Widget>[];
    int expenseIndex = 0;
    int settlementIndex = 0;

    while (expenseIndex < _expenses.length ||
        settlementIndex < _settlements.length) {
      bool takeExpense;
      if (settlementIndex >= _settlements.length) {
        takeExpense = true; // only expenses are left
      } else if (expenseIndex >= _expenses.length) {
        takeExpense = false; // only payments are left
      } else {
        final expenseDate = _expenses[expenseIndex].expenseDate;
        final settlementDate = _settlements[settlementIndex].settledAt;
        takeExpense = expenseDate >= settlementDate;
      }

      if (takeExpense) {
        final expense = _expenses[expenseIndex];
        tiles.add(
          ExpenseTile(
            expense: expense,
            payerName: _memberName(expense.paidBy),
            onTap: () => _openEditExpense(expense),
            onLongPress: () => _deleteExpense(expense),
          ),
        );
        expenseIndex++;
      } else {
        final settlement = _settlements[settlementIndex];
        tiles.add(
          SettlementTile(
            settlement: settlement,
            fromName: _memberName(settlement.fromUserId),
            toName: _memberName(settlement.toUserId),
            onLongPress: () => _deleteSettlement(settlement),
          ),
        );
        settlementIndex++;
      }
    }
    return tiles;
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
