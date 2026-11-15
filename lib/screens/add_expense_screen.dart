import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/group.dart';
import '../services/expense_service.dart';
import '../utils/expense_categories.dart';
import '../utils/money.dart';
import '../utils/split_calculator.dart';

// Asks for the details of a new expense and how to split it, then saves
// it. Works offline: the expense is saved on the phone and synced later.
// On success it closes and returns true to the group screen.
class AddExpenseScreen extends StatefulWidget {
  final Group group;
  // The members of the group: maps with 'user_id', 'name' and 'role'.
  final List<Map<String, Object?>> members;
  // The signed-in user; chosen as the payer at first. It is a parameter
  // (not read from AuthService here) so tests do not need Firebase.
  final String currentUserId;

  const AddExpenseScreen({
    super.key,
    required this.group,
    required this.members,
    required this.currentUserId,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  late String _paidBy;
  String _category = 'food';
  DateTime _expenseDate = DateTime.now();
  String _splitType = 'equal'; // 'equal', 'percentage' or 'exact'

  // Equal split: the members who share the expense (everybody at first).
  final Set<String> _selectedMembers = {};
  // Percentage and exact split: one text field for every member.
  final Map<String, TextEditingController> _percentControllers = {};
  final Map<String, TextEditingController> _exactControllers = {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    for (final member in widget.members) {
      final userId = member['user_id'] as String;
      _selectedMembers.add(userId);
      _percentControllers[userId] = TextEditingController();
      _exactControllers[userId] = TextEditingController();
    }

    // I paid, unless I am not in the member list for some reason.
    _paidBy = widget.members.first['user_id'] as String;
    for (final member in widget.members) {
      if (member['user_id'] == widget.currentUserId) {
        _paidBy = widget.currentUserId;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    for (final controller in _percentControllers.values) {
      controller.dispose();
    }
    for (final controller in _exactControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // The amount in the amount field in kuruş, or null if it is not valid.
  int? _typedAmount() {
    final amount = parseMoney(_amountController.text);
    if (amount == null || amount <= 0) {
      return null;
    }
    return amount;
  }

  // The members who are ticked for the equal split, in list order.
  List<String> _selectedMemberIds() {
    final userIds = <String>[];
    for (final member in widget.members) {
      final userId = member['user_id'] as String;
      if (_selectedMembers.contains(userId)) {
        userIds.add(userId);
      }
    }
    return userIds;
  }

  // The typed percentages; empty fields and 0 are left out.
  // Returns null if a field is not a whole number.
  Map<String, int>? _readPercentages() {
    final percentages = <String, int>{};
    for (final userId in _percentControllers.keys) {
      final text = _percentControllers[userId]!.text.trim();
      if (text.isEmpty) {
        continue;
      }
      final percent = int.tryParse(text);
      if (percent == null || percent < 0) {
        return null;
      }
      if (percent > 0) {
        percentages[userId] = percent;
      }
    }
    return percentages;
  }

  // The typed amounts in kuruş; empty fields and 0 are left out.
  // Returns null if a field is not a valid amount.
  Map<String, int>? _readExactAmounts() {
    final amounts = <String, int>{};
    for (final userId in _exactControllers.keys) {
      final text = _exactControllers[userId]!.text.trim();
      if (text.isEmpty) {
        continue;
      }
      final amount = parseMoney(text);
      if (amount == null) {
        return null;
      }
      if (amount > 0) {
        amounts[userId] = amount;
      }
    }
    return amounts;
  }

  // Builds the share of every person from what the user chose.
  // Shows a message and returns null if the split is not right.
  Map<String, int>? _buildShares(AppLocalizations texts, int amount) {
    if (_splitType == 'equal') {
      final userIds = _selectedMemberIds();
      if (userIds.isEmpty) {
        _showMessage(texts.splitErrorNobody);
        return null;
      }
      return splitEqually(amount, userIds, _paidBy);
    }

    if (_splitType == 'percentage') {
      final percentages = _readPercentages();
      if (percentages == null || !percentagesAddUpTo100(percentages)) {
        _showMessage(texts.splitErrorPercent);
        return null;
      }
      return splitByPercentage(amount, percentages, _paidBy);
    }

    final amounts = _readExactAmounts();
    if (amounts == null || !sharesMatchAmount(amount, amounts)) {
      _showMessage(texts.splitErrorExact);
      return null;
    }
    return amounts;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _expenseDate = picked;
    });
  }

  Future<void> _save() async {
    final texts = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }
    final amount = _typedAmount()!;
    final shares = _buildShares(texts, amount);
    if (shares == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ExpenseService.addExpense(
        groupId: widget.group.id,
        title: _titleController.text.trim(),
        amount: amount,
        paidBy: _paidBy,
        category: _category,
        expenseDate: _expenseDate.millisecondsSinceEpoch,
        splitType: _splitType,
        shares: shares,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
      return;
    } catch (error) {
      if (mounted) {
        _showMessage(texts.errorUnknown);
      }
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(texts.addExpenseTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: texts.expenseTitleLabel),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return texts.expenseTitleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: texts.amountLabel),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                // Rebuild so the equal shares below show the new amount.
                onChanged: (value) => setState(() {}),
                validator: (value) {
                  if (_typedAmount() == null) {
                    return texts.amountInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPaidByField(texts),
              const SizedBox(height: 16),
              _buildCategoryField(texts),
              const SizedBox(height: 16),
              _buildDateField(texts),
              const SizedBox(height: 24),
              Text(
                texts.splitLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildSplitTypeButtons(texts),
              const SizedBox(height: 8),
              ..._buildMemberRows(),
              _buildSplitTotal(texts),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(texts.saveExpenseButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaidByField(AppLocalizations texts) {
    final items = <DropdownMenuItem<String>>[];
    for (final member in widget.members) {
      items.add(
        DropdownMenuItem(
          value: member['user_id'] as String,
          child: Text(member['name'] as String),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _paidBy,
      // Same text style as the text fields above (a dropdown is bold
      // by default).
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(labelText: texts.paidByLabel),
      items: items,
      onChanged: (value) {
        setState(() {
          _paidBy = value!;
        });
      },
    );
  }

  Widget _buildCategoryField(AppLocalizations texts) {
    final items = <DropdownMenuItem<String>>[];
    for (final category in expenseCategories) {
      items.add(
        DropdownMenuItem(
          value: category,
          child: Row(
            children: [
              Icon(categoryIcon(category), size: 20),
              const SizedBox(width: 12),
              Text(categoryName(texts, category)),
            ],
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _category,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(labelText: texts.categoryLabel),
      items: items,
      onChanged: (value) {
        setState(() {
          _category = value!;
        });
      },
    );
  }

  // Looks like a text field; tapping it opens the date picker.
  Widget _buildDateField(AppLocalizations texts) {
    final dateText = MaterialLocalizations.of(
      context,
    ).formatMediumDate(_expenseDate);

    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: texts.expenseDateLabel,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(dateText),
      ),
    );
  }

  Widget _buildSplitTypeButtons(AppLocalizations texts) {
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(value: 'equal', label: Text(texts.splitEqual)),
        ButtonSegment(value: 'percentage', label: Text(texts.splitPercentage)),
        ButtonSegment(value: 'exact', label: Text(texts.splitExact)),
      ],
      selected: {_splitType},
      onSelectionChanged: (selection) {
        setState(() {
          _splitType = selection.first;
        });
      },
    );
  }

  // One row for every member. What the row shows depends on the split type.
  List<Widget> _buildMemberRows() {
    // For the equal split, show what everybody will pay.
    Map<String, int> equalShares = {};
    final amount = _typedAmount();
    final selectedIds = _selectedMemberIds();
    if (_splitType == 'equal' && amount != null && selectedIds.isNotEmpty) {
      equalShares = splitEqually(amount, selectedIds, _paidBy);
    }

    final rows = <Widget>[];
    for (final member in widget.members) {
      final userId = member['user_id'] as String;
      final name = member['name'] as String;

      if (_splitType == 'equal') {
        String shareText = '';
        if (equalShares.containsKey(userId)) {
          shareText = formatMoney(equalShares[userId]!);
        }
        rows.add(
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(name),
            secondary: Text(shareText),
            value: _selectedMembers.contains(userId),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _selectedMembers.add(userId);
                } else {
                  _selectedMembers.remove(userId);
                }
              });
            },
          ),
        );
      } else if (_splitType == 'percentage') {
        rows.add(
          _buildMemberInputRow(
            name,
            _percentControllers[userId]!,
            '%',
            TextInputType.number,
          ),
        );
      } else {
        rows.add(
          _buildMemberInputRow(
            name,
            _exactControllers[userId]!,
            '₺',
            const TextInputType.numberWithOptions(decimal: true),
          ),
        );
      }
    }
    return rows;
  }

  // A member name with a small text field on the right.
  Widget _buildMemberInputRow(
    String name,
    TextEditingController controller,
    String suffix,
    TextInputType keyboardType,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(name),
      trailing: SizedBox(
        width: 120,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: TextAlign.end,
          // Smaller padding than a normal field, so it fits in the row.
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            suffixText: suffix,
          ),
          // Rebuild so the total below is updated.
          onChanged: (value) => setState(() {}),
        ),
      ),
    );
  }

  // Under the percentage and amount fields: the total so far. It is shown
  // in the error color until it is right.
  Widget _buildSplitTotal(AppLocalizations texts) {
    if (_splitType == 'equal') {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;
    String text;
    bool isRight;

    if (_splitType == 'percentage') {
      int total = 0;
      for (final controller in _percentControllers.values) {
        total += int.tryParse(controller.text.trim()) ?? 0;
      }
      text = texts.splitPercentTotal(total);
      isRight = total == 100;
    } else {
      int total = 0;
      for (final controller in _exactControllers.values) {
        total += parseMoney(controller.text) ?? 0;
      }
      final amount = _typedAmount() ?? 0;
      text = texts.splitExactTotal(formatMoney(total), formatMoney(amount));
      isRight = amount > 0 && total == amount;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: TextStyle(color: isRight ? colors.primary : colors.error),
      ),
    );
  }
}
