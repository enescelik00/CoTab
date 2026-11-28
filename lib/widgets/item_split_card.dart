import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

// One receipt item while the expense form is open: what the user typed
// and who had the item. The expense screen keeps a list of these.
// id is set when the item is already saved (editing); null for a new one.
class ItemDraft {
  final String? id;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final Set<String> userIds;

  ItemDraft({
    this.id,
    String name = '',
    String amount = '',
    Set<String>? userIds,
  }) : nameController = TextEditingController(text: name),
       amountController = TextEditingController(text: amount),
       userIds = userIds ?? {};

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

// The card of one item in the item split: name and amount fields, a chip
// for every member to choose who had it, and a remove button.
class ItemSplitCard extends StatelessWidget {
  final ItemDraft draft;
  // The people who can be chosen: maps with 'user_id' and a ready 'name'.
  final List<Map<String, String>> people;
  // Called after every change, so the screen can update the totals.
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const ItemSplitCard({
    super.key,
    required this.draft,
    required this.people,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: draft.nameController,
                    decoration: InputDecoration(labelText: texts.itemNameLabel),
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value) => onChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: draft.amountController,
                    decoration: InputDecoration(labelText: texts.amountLabel),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) => onChanged(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: texts.removeItemTooltip,
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              texts.itemWhoHadIt,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final person in people)
                  FilterChip(
                    label: Text(person['name']!),
                    selected: draft.userIds.contains(person['user_id']),
                    onSelected: (selected) {
                      if (selected) {
                        draft.userIds.add(person['user_id']!);
                      } else {
                        draft.userIds.remove(person['user_id']);
                      }
                      onChanged();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
