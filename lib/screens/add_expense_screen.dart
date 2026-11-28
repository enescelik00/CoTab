import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/expense.dart';
import '../models/expense_item.dart';
import '../models/expense_share.dart';
import '../models/group.dart';
import '../services/expense_service.dart';
import '../utils/expense_categories.dart';
import '../utils/money.dart';
import '../utils/split_calculator.dart';
import '../widgets/item_split_card.dart';

// Asks for the details of an expense and how to split it, then saves it.
// The same screen adds a new expense and edits an existing one: when
// expense is given, the form starts filled with it.
// Works offline: the expense is saved on the phone and synced later.
// On success it closes and returns true to the group screen.
class AddExpenseScreen extends StatefulWidget {
  final Group group;
  // The members of the group: maps with 'user_id', 'name' and 'role'.
  final List<Map<String, Object?>> members;
  // The signed-in user; chosen as the payer at first. It is a parameter
  // (not read from AuthService here) so tests do not need Firebase.
  final String currentUserId;
  // Only when editing: the expense and its current shares.
  final Expense? expense;
  final List<ExpenseShare> shares;
  // The receipt items. When editing an item split, these are its saved
  // items. For a new expense (for example from a scanned receipt), they
  // start the form in the item split; their ids are not used.
  final List<ExpenseItem> items;

  const AddExpenseScreen({
    super.key,
    required this.group,
    required this.members,
    required this.currentUserId,
    this.expense,
    this.shares = const [],
    this.items = const [],
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
  // 'equal', 'percentage', 'exact' or 'items'
  String _splitType = 'equal';

  // Equal split: the members who share the expense (everybody at first).
  final Set<String> _selectedMembers = {};
  // Percentage and exact split: one text field for every member.
  final Map<String, TextEditingController> _percentControllers = {};
  final Map<String, TextEditingController> _exactControllers = {};
  // Item split: one draft for every receipt item.
  final List<ItemDraft> _itemDrafts = [];

  // The people shown in the form: the members of the group and, when
  // editing, also anybody in the expense who is not a member any more.
  // Without them, saving would silently drop their share.
  final List<Map<String, Object?>> _formMembers = [];

  bool _isSaving = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _formMembers.addAll(widget.members);

    final expense = widget.expense;
    if (expense != null) {
      _addMissingPerson(expense.paidBy);
      for (final share in widget.shares) {
        _addMissingPerson(share.userId);
      }
    }

    for (final member in _formMembers) {
      final userId = member['user_id'] as String;
      _selectedMembers.add(userId);
      _percentControllers[userId] = TextEditingController();
      _exactControllers[userId] = TextEditingController();
    }

    if (expense != null) {
      _fillFormFrom(expense);
      return;
    }

    // A new expense with items, for example from a scanned receipt. Like
    // "Add item", every item is shared by everybody at first.
    if (widget.items.isNotEmpty) {
      _splitType = 'items';
      for (final item in widget.items) {
        _itemDrafts.add(
          ItemDraft(
            name: item.name,
            amount: formatMoneyForInput(item.amount),
            userIds: Set<String>.from(_selectedMembers),
          ),
        );
      }
    }

    // I paid, unless I am not in the member list for some reason.
    _paidBy = _formMembers.first['user_id'] as String;
    for (final member in _formMembers) {
      if (member['user_id'] == widget.currentUserId) {
        _paidBy = widget.currentUserId;
      }
    }
  }

  // Adds a person to the form who is not a member any more. Their name is
  // not known, so it is shown as "Unknown" (see _nameOf).
  void _addMissingPerson(String userId) {
    for (final member in _formMembers) {
      if (member['user_id'] == userId) {
        return;
      }
    }
    _formMembers.add({'user_id': userId, 'name': null, 'role': 'member'});
  }

  // Editing: puts the saved expense and its shares into the form.
  void _fillFormFrom(Expense expense) {
    _titleController.text = expense.title;
    _amountController.text = formatMoneyForInput(expense.amount);
    _paidBy = expense.paidBy;
    // A category that is not in the list would crash the dropdown.
    _category = 'other';
    if (expenseCategories.contains(expense.category)) {
      _category = expense.category;
    }
    _expenseDate = DateTime.fromMillisecondsSinceEpoch(expense.expenseDate);
    _splitType = expense.splitType;

    // What every person pays in total. For an item split a person has one
    // share per item, so they are added up.
    final shares = <String, int>{};
    for (final share in widget.shares) {
      shares[share.userId] = (shares[share.userId] ?? 0) + share.amount;
    }

    for (final item in widget.items) {
      final userIds = <String>{};
      for (final share in widget.shares) {
        if (share.itemId == item.id) {
          userIds.add(share.userId);
        }
      }
      _itemDrafts.add(
        ItemDraft(
          id: item.id,
          name: item.name,
          amount: formatMoneyForInput(item.amount),
          userIds: userIds,
        ),
      );
    }

    // The people in the split are ticked; this is also used when the user
    // switches to the equal split while editing.
    _selectedMembers.clear();
    _selectedMembers.addAll(shares.keys);

    final percentages = percentagesFromShares(expense.amount, shares);
    for (final userId in shares.keys) {
      _percentControllers[userId]!.text = percentages[userId].toString();
      _exactControllers[userId]!.text = formatMoneyForInput(shares[userId]!);
    }
  }

  String _nameOf(Map<String, Object?> member) {
    final name = member['name'];
    if (name == null) {
      return AppLocalizations.of(context)!.unknownMember;
    }
    return name as String;
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
    for (final draft in _itemDrafts) {
      draft.dispose();
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
    for (final member in _formMembers) {
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

  // Item split: reads the item cards. Shows a message and returns null if
  // an item is not complete or the items do not add up to the amount.
  // The people of every item are in the order of the form.
  List<ItemSplit>? _readItems(AppLocalizations texts, int amount) {
    if (_itemDrafts.isEmpty) {
      _showMessage(texts.splitErrorNoItems);
      return null;
    }

    final items = <ItemSplit>[];
    int total = 0;
    for (final draft in _itemDrafts) {
      final name = draft.nameController.text.trim();
      final itemAmount = parseMoney(draft.amountController.text);
      final userIds = <String>[];
      for (final member in _formMembers) {
        final userId = member['user_id'] as String;
        if (draft.userIds.contains(userId)) {
          userIds.add(userId);
        }
      }

      if (name.isEmpty ||
          itemAmount == null ||
          itemAmount <= 0 ||
          userIds.isEmpty) {
        _showMessage(texts.splitErrorItem);
        return null;
      }
      items.add(
        ItemSplit(
          id: draft.id,
          name: name,
          amount: itemAmount,
          userIds: userIds,
        ),
      );
      total += itemAmount;
    }

    if (total != amount) {
      _showMessage(texts.splitErrorItemsTotal);
      return null;
    }
    return items;
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

    // An item split saves items; every other split saves shares.
    Map<String, int> shares = {};
    List<ItemSplit> items = [];
    if (_splitType == 'items') {
      final readItems = _readItems(texts, amount);
      if (readItems == null) {
        return;
      }
      items = readItems;
    } else {
      final builtShares = _buildShares(texts, amount);
      if (builtShares == null) {
        return;
      }
      shares = builtShares;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditing) {
        await ExpenseService.updateExpense(
          widget.expense!,
          title: _titleController.text.trim(),
          amount: amount,
          paidBy: _paidBy,
          category: _category,
          expenseDate: _expenseDate.millisecondsSinceEpoch,
          splitType: _splitType,
          shares: shares,
          items: items,
        );
      } else {
        await ExpenseService.addExpense(
          groupId: widget.group.id,
          title: _titleController.text.trim(),
          amount: amount,
          paidBy: _paidBy,
          category: _category,
          expenseDate: _expenseDate.millisecondsSinceEpoch,
          splitType: _splitType,
          shares: shares,
          items: items,
        );
      }
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
      appBar: AppBar(
        title: Text(
          _isEditing ? texts.editExpenseTitle : texts.addExpenseTitle,
        ),
      ),
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
              if (_splitType == 'items')
                ..._buildItemRows(texts)
              else
                ..._buildMemberRows(),
              _buildSplitTotal(texts),
              if (_splitType == 'items') _buildItemsPerPerson(texts),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing
                            ? texts.saveChangesButton
                            : texts.saveExpenseButton,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaidByField(AppLocalizations texts) {
    final items = <DropdownMenuItem<String>>[];
    for (final member in _formMembers) {
      items.add(
        DropdownMenuItem(
          value: member['user_id'] as String,
          child: Text(_nameOf(member)),
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
        ButtonSegment(value: 'items', label: Text(texts.splitItems)),
      ],
      // Four segments: no check mark, so the labels fit on a phone.
      showSelectedIcon: false,
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
    for (final member in _formMembers) {
      final userId = member['user_id'] as String;
      final name = _nameOf(member);

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
    } else if (_splitType == 'items') {
      int total = 0;
      for (final draft in _itemDrafts) {
        total += parseMoney(draft.amountController.text) ?? 0;
      }
      final amount = _typedAmount() ?? 0;
      text = texts.splitExactTotal(formatMoney(total), formatMoney(amount));
      isRight = amount > 0 && total == amount;
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

  // The people for the item chips, with their names ready to show.
  List<Map<String, String>> _peopleForChips() {
    final people = <Map<String, String>>[];
    for (final member in _formMembers) {
      people.add({
        'user_id': member['user_id'] as String,
        'name': _nameOf(member),
      });
    }
    return people;
  }

  // Item split: one card for every item and a button to add one more.
  List<Widget> _buildItemRows(AppLocalizations texts) {
    final people = _peopleForChips();
    final rows = <Widget>[];
    for (final draft in _itemDrafts) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ItemSplitCard(
            // The key keeps every card with its own draft when one above it
            // is removed.
            key: ObjectKey(draft),
            draft: draft,
            people: people,
            onChanged: () => setState(() {}),
            onRemove: () {
              setState(() {
                _itemDrafts.remove(draft);
              });
              // The card's text fields are taken off the screen in the next
              // build. Their controllers are freed only after that, so the
              // fields never hold a controller that is already freed.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                draft.dispose();
              });
            },
          ),
        ),
      );
    }

    rows.add(
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: OutlinedButton.icon(
          onPressed: () {
            setState(() {
              // A new item is shared by everybody at first.
              final everybody = <String>{};
              for (final person in people) {
                everybody.add(person['user_id']!);
              }
              _itemDrafts.add(ItemDraft(userIds: everybody));
            });
          },
          icon: const Icon(Icons.add),
          label: Text(texts.addItemButton),
        ),
      ),
    );
    return rows;
  }

  // Item split: what every person pays in total, for the items that are
  // complete so far (an amount and at least one person).
  Widget _buildItemsPerPerson(AppLocalizations texts) {
    final items = <ItemSplit>[];
    for (final draft in _itemDrafts) {
      final amount = parseMoney(draft.amountController.text);
      if (amount == null || amount <= 0 || draft.userIds.isEmpty) {
        continue;
      }
      final userIds = <String>[];
      for (final member in _formMembers) {
        final userId = member['user_id'] as String;
        if (draft.userIds.contains(userId)) {
          userIds.add(userId);
        }
      }
      items.add(ItemSplit(name: '', amount: amount, userIds: userIds));
    }
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final totals = splitByItems(items, _paidBy);
    final rows = <Widget>[];
    for (final member in _formMembers) {
      final userId = member['user_id'] as String;
      if (!totals.containsKey(userId)) {
        continue;
      }
      rows.add(
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(_nameOf(member)),
          trailing: Text(formatMoney(totals[userId]!)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            texts.itemsPerPerson,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          ...rows,
        ],
      ),
    );
  }
}
